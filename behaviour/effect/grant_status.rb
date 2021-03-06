module Effect
	class GrantStatus < Effect::ActOnTick

		def initialize(parent, interval, status, target = :character, overlap_mode = :refresh)
			super parent, interval
			@status = Entity::StatusType.find status
			@target = target.to_sym
			@overlap = overlap_mode.to_sym
		end

		def tick_event(*args)
			source = args[0]
			source = source.stateful if source.is_a? Entity::Status
			source = source.carrier if source.is_a? Entity::Item
			target = super *args
			target = target.stateful if target.is_a? Entity::Status
			target = target.carrier if target.is_a?(Entity::Item) && @target != :item
			target = target.location if @target == :tile && target.is_a?(Entity::Character)

			if target.is_a?(Entity::Tile) && @target == :character
				target.characters.each do |char|
					if args.count > 1
						self.send(('tick_' + @interval.to_s).to_sym, [args[0], char])
					else
						self.send(('tick_' + @interval.to_s).to_sym, char)
					end
				end
			else
				# Apply status effect to entity

				found = nil
				apply = true

				unless @overlap == :stack
					target.statuses.each do |ent_status|
						if ent_status.link == @status.id
							found = ent_status
							break
						end
					end
				end
				max_duration = 0
				# find max duration if relevant
				if found != nil && (@overlap == :refresh || @overlap == :extend)
					found.effects.each do |effect|
						if effect.respond_to? :max_duration
							max_duration = effect.max_duration
							break
						end
					end
				end

				case @overlap
					when :overwrite
						found.dispel unless found === nil
					when :extend # Extend found status by max_duration
						unless found === nil
							apply = false
							existing_dur = found.get_tag(:duration) if found.respond_to? :get_tag
							existing_dur = max_duration if existing_dur === nil
							found.set_tag(:duration, existing_dur.to_i + max_duration) if found.respond_to?(:set_tag)
						end
					when :ignore # Do nothing
						apply = false unless found === nil
					when :refresh # Refresh found status to max duration
						unless found === nil
							apply = false
							found.set_tag(:duration, max_duration) if found.respond_to?(:set_tag)
						end
					when :stack # apply duplicate status
						# always apply status
				end

				if apply
					nstatus = Entity::Status.source_from @status.id
					nstatus.source = source
					nstatus.stateful = target
					Entity::Status.tick nstatus, StatusTick::STATUS_CREATED, *args
				end
				return BroadcastScope::SELF
			end
		end

		def describe
			super + "#{@target} gain #{@status.name}. #{@overlap} if duplicates."
		end

		def save_state
			super.push @status.id, @target, @max_overlap
		end
	end
end