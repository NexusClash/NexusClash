module Effect
	class FirstAidKit < Effect::ActivatedTarget

		def initialize(parent, name = 'First Aid Kit', healing = 5)
			super parent, {ap: 1}, name, [:self, Entity::Character]
			@healing = healing
			@costs[:destroy_item] = self.method :destroy_item
			@costs[:apply_healing] = self.method :apply_healing
			unserialise
		end

		def unserialise
			@item = @parent.stateful if @parent.respond_to? :stateful
		end

		def activate_target_intent(intent)
			intent.name = name
			@costs.each do |cost, delta|
				intent.add_cost cost, delta
			end
		end

		def destroy_item(action, intent)
			case action
				when :possible?
					return true
				when :apply_costs
					intent.entity.items.each do |item|
						item.type_statuses.each do |status|
							if status == intent.target
								puts 'found!'
								item.despawn
								return
							end
						end
						item.statuses.each do |status|
							if status == intent.target
								puts 'found!'
								item.despawn
								return
							end
						end
					end
			end
		end

		def apply_healing(action, intent)
			case action
				when :possible?
					if intent.respond_to? :target_entity
						return intent.target_entity.hp < intent.target_entity.hp_max
					else
						return intent.entity.hp < intent.entity.hp_max
					end
				when :apply_costs
					source = intent.entity
					if intent.respond_to? :target_entity
						target = intent.target_entity
					else
						target = source
					end

					amount_modification = 0

					source.each_applicable_effect do |effect|
						amount_modification += effect.increase_healing(source, target, @amount)  if effect.respond_to? :increase_healing
					end
					source.location.statuses.each do |status|
						status.effects.each do |effect|
							amount_modification += effect.increase_healing(source, target, @amount)  if effect.respond_to? :increase_healing
						end
					end

					initialval = target.hp
					val = initialval
					delta = @healing + amount_modification
					max = target.hp_max
					if val + @healing > max then
						if val > max
							delta = 0
						else
							delta = max - val
							val = max
						end
					else
						val += @healing
					end
					target.hp = val

					if target != source
						source.xp += delta
						source.mo += delta
						m = Entity::Message.new({characters: [source.id], type: MessageType::GENERIC, message: "You use your #{name} to heal #{target.name_link} for #{delta} HP. You gain #{delta} XP."})
						m.save
						m = Entity::Message.new({characters: [target.id], type: MessageType::GENERIC, message: "#{source.name_link} used #{source.pronoun :his} #{name} to heal you for #{delta} HP."})
						m.save
						source.broadcast_self BroadcastScope::SELF
						target.broadcast_self BroadcastScope::TILE
					else
						m = Entity::Message.new({characters: [target.id], type: MessageType::GENERIC, message: "You heal yourself for #{delta} HP using your #{name}."})
						m.save
						source.broadcast_self BroadcastScope::TILE
					end

			end
		end

		def describe
			super + " It heals the target for #{@healing} HP (affected by effects that increase healing) and consumes the item."
		end

		def save_state
			['FirstAidKit', @name, @amount]
		end
	end
end