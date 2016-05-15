module Effect
	class HealingOnTick < Effect::ActOnTick

		def initialize(parent, interval, amount)
			super parent, interval
			@amount = amount.to_i
		end

		def tick_event(*target)
			target = super *target
			target = target.carrier if target.is_a? Entity::Item

			if target.is_a? Entity::Tile
				target.characters.each do |char|
					self.send(('tick_' + @interval.to_s).to_sym, char)
				end
			else
				initialval = target.hp
				val = initialval
				delta = @amount
				max = target.hp_max
				if val + @amount > max then
					if val > max
						delta = 0
					else
						delta = max - val
						val = max
					end
				else
					val += @amount
				end

				target.hp = val

				@parent.temp_effect_vars[:hp] = delta

				return BroadcastScope::NONE if val == initialval

				unless @parent.source === nil
					source = @parent.source
					source.xp += delta
					source.mo += delta
					source.broadcast_self BroadcastScope::SELF
					m = Entity::Message.new({characters: [source.id], type: MessageType::GENERIC, message: "You gain #{delta} XP from healing #{target.name_link} with #{@parent.name}."})
					m.save
				end

				m = Entity::Message.new({characters: [target.id], type: MessageType::GENERIC, message: "You gain #{delta} HP from #{@parent.name}."})
				m.save

				return BroadcastScope::TILE
			end
		end

		def describe
			super + "gain #{@amount.to_s} HP."
		end

		def save_state
			super.push @type, @amount
		end
	end
end