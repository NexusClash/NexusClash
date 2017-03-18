module Intent
	class Search < Action

		def initialize(entity)
			super entity
			@message = ''
			add_cost :ap, 1
		end

		def take_action
			item_drop = nil
			item_drop = entity.location.type.search_roll_item if search_succeeded?

			if item_drop === nil
				message_ent = Entity::Message.new({characters: [entity.id], message: 'You search and find nothing.', type: MessageType::SEARCH_NOTHING})
				message_ent.save
			else
				message_ent = Entity::Message.new({characters: [entity.id], message: "You search and find #{item_drop.a_or_an} #{item_drop.name}.", type: MessageType::SEARCH_SUCCESS})
				message_ent.save
				item_drop.carrier = entity

				packet = {packets:[{type: 'inventory', weight: entity.weight, weight_max: entity.weight_max, list: 'add', items: [item_drop.to_h]}]}

				entity.broadcast BroadcastScope::SELF, packet.to_json
			end

			if rand(1..100) < 25
				entity.location.characters.each do |char|
					if !char.visible_to?(entity) && char.visibility == Visibility::HIDING
						char.reveal_to! entity
						message_ent = Entity::Message.new({characters: [entity.id], message: "You find #{char.name_link} while searching. #{char.pronoun(:he)} is hiding.", type: MessageType::SEARCH_SUCCESS})
						message_ent.save
						break
					end
				end
			end
		end

		def broadcast_results
			entity.broadcast_self BroadcastScope::SELF
		end

		def search_succeeded?
			current_plane = Firmament::Plane.fetch(entity.location.plane)

			search_modifier = current_plane.is_day? ? 1.0 : 0.9
			roll = rand(0..99)
			modified_roll = roll * search_modifier

			success = modified_roll < entity.location.type.search_rate

			debug "Success? #{success ? 'Yes' : 'No'} Roll? #{modified_roll} Target? #{entity.location.type.search_rate}" if Instance.debug
		end
	end
end
