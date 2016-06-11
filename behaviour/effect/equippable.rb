module Effect
	class Equippable < Effect::Activated

		attr_reader :slot

		def initialize(parent, slot = nil)
			super parent
			@slot = slot
		end

		def equipped?
			@parent.get_tag(:equipped)
		end

		def name
			equipped? ? 'Unequip' : 'Equip'
		end

		def activate_self_intent(intent)
			intent.name = name
			intent.add_cost(:ap, 1) unless equipped?
			intent.add_cost :toggle_equip, self.method(:equip_toggle)
		end

		def describe
			desc = "#{@parent.name} can be equipped"
			desc << " into the #{slot} slot" unless slot === nil
			desc << '.'
			desc
		end

		def save_state
			if slot === nil
				['Equippable']
			else
				['Equippable', slot]
			end
		end

		def equip_toggle(action, intent)
			target = intent.target
			character = intent.entity
			case action
				when :possible?
					result = true
					equipped = equipped?
					free = slot_free?(character, slot)
					result = false unless equipped || free
					if result
						intent.debug "Able to equip into #{slot}" unless slot === nil
					else
						intent.debug "Slot #{slot} isn't available!" if !equipped && !free
					end
				when :apply_costs
					if equipped?
						intent.debug 'Unequipping'
						@parent.set_tag :equipped, false
						@parent.set_tag :slot, nil
					else
						intent.debug 'Equipping'
						@parent.set_tag :equipped, true
						@parent.set_tag :slot, slot
					end
					if equipped?
						msg = "You equip your #{target.name}"
					else
						msg = "You unequip your #{target.name}"
					end
					msg_equip = Entity::Message.new({characters: [character.id], message: msg, type: MessageType::GENERIC})
					msg_equip.save
					intent.entity.broadcast_self BroadcastScope::SELF
					intent.entity.broadcast BroadcastScope::SELF, {packets:[{type: 'inventory', list: 'update', items: [target.to_h]}]}.to_json
			end
			result
		end

		private

		def slot_free?(character, slot)
			return true if slot === nil
			character.items.each do |item|
				item.statuses.each do |status|
					item_slot = status.get_tag :slot
					return false if item_slot == slot
				end
			end
			true
		end

	end
end