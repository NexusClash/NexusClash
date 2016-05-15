module Effect
	# Ability doesn't work cross-plane yet... Also needs to rebuild link on server restart
	class AlonaiAegisAbility < ActivatedTarget

		def initialize(parent, costs = {ap: 1}, name = 'Alonai\'s Aegis')
			super parent, costs, name, [Entity::Character]
			@costs[:mo_check] = self.method(:mo_check)
			@costs[:apply_buff] = self.method(:apply_buff)
			#@status = Entity::StatusType.find status
			@mo_source = nil
			@mo_target = nil
		end

		def can_target?(tar)
			tar.is_a? Entity::Character
		end

		def activate_target_intent(intent)
			intent.name = name
			@costs.each do |cost, delta|
				intent.add_cost cost, delta
			end
		end

		def describe
			"#{name} is a targetted ability, costing #{@costs[:ap]} AP + #{@costs[:mp]} MP."
		end

		def save_state
			['AlonaiAegisAbility', @costs, @name]
		end

		def apply_buff(action, intent)
			result = true
			case action
				when :possible?
					target_id = intent.entity.get_tag :alonai_aegis_target
					if target_id === nil
						result = true
					else
						game = Firmament::Plane.fetch Instance.plane
						target_char = game.character target_id
						result = target_char.mo_hook === nil
						intent.entity.set_tag(:alonai_aegis_target, nil) if result
					end
				when :apply_costs
					intent.entity.set_tag :alonai_aegis_target, intent.target_entity.id

					#nstatus = Entity::Status.source_from @status.id
					#nstatus.stateful = intent.target_entity

					intent.target_entity.mo_hook = self
					@mo_source = intent.entity
					@mo_target = intent.target_entity

					m = Entity::Message.new({characters: [intent.entity.id], type: MessageType::GENERIC, message: "You wave your hands over #{@mo_target.name}."})
					m.save
					m = Entity::Message.new({characters: [intent.target_entity.id], type: MessageType::GENERIC, message: "You are now under the effects of Alonai's Aegis cast by #{@mo_source.name}"})
					m.save
			end
			result
		end

		def mo_check(action, intent)
			if action == :possible?
				result = intent.entity.alignment == :good
				if result == false
					m = Entity::Message.new({characters: [intent.entity.id], type: MessageType::FAILED, message: 'You can\'t use Alona\'s Aegis unless your alignment is good!'})
					m.save
				end
				return result
			end
		end

		# Morality hook

		def mo
			@mo_source.mo
		end

		def mo=(val)
			delta = val - @mo_target.mo
			if delta > 0
				m = Entity::Message.new({characters: [@mo_source.id], type: MessageType::GENERIC, message: "You feel a warm fuzzy feeling inside as #{@mo_target.name} does a good deed - They have gained #{delta / 10} morality!"})
				m.save
				m = Entity::Message.new({characters: [@mo_target.id], type: MessageType::GENERIC, message: 'You feel like your action has made the world a better place...'})
				m.save
			else
				m = Entity::Message.new({characters: [@mo_source.id], type: MessageType::GENERIC, message: "#{@mo_target.name} has performed a deed most dark... You lose #{delta / 10} absolving them of their sins."})
				m.save
				m = Entity::Message.new({characters: [@mo_target.id], type: MessageType::GENERIC, message: 'Despite your evil act, you feel remarkably innocent...'})
				m.save
				val = @mo_target.mo
				@mo_source.mo += delta * 2
				unless @mo_source.alignment == :good
					m = Entity::Message.new({characters: [@mo_source.id], type: MessageType::GENERIC, message: "You are no longer good enough to absolve #{@mo_target.name} of their sins, the effect has ended."})
					m.save
					@mo_target.mo_hook = nil
					@mo_source.set_tag(:alonai_aegis_target, nil)
				end
				@mo_source.broadcast_self BroadcastScope::SELF
			end
			@mo_target.mo # Prevent change
		end

	end
end