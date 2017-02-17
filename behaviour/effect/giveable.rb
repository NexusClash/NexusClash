module Effect
	class Giveable

		attr_accessor :parent

		def initialize(parent)
			@parent = parent
		end

		def describe
			"May be given to other characters."
		end

		def save_state
			['Giveable']
		end
		
		def item
			return @item unless @item.nil?
			giveable = parent.parent if parent.respond_to?(:parent)
			@item = giveable if giveable.is_a?(Entity::Item)
		end

		def activate_target_intent(intent)
			intent.name = "Give #{item.name}"
			intent.remove_cost :encumbrance_check_callback
			intent.add_cost(:give_callback, self.method(:give_callback))
		end
		
		def give_callback(method, intent)
			case method
				when :possible?
					return possible?(intent.target_entity)
				when :apply_costs
					give(intent.entity, intent.target_entity)
			end
		end
		
		def possible?(recipient)
			recipient_has_room = recipient.respond_to?(:weight) &&
				recipient.respond_to?(:weight_max ) &&
				(recipient.weight + item.weight) <= recipient.weight_max
			unless recipient_has_room
				Entity::Message.send_transient([item.carrier.id], "#{recipient.name_link} does not have room for your #{item.name}.", MessageType::FAILED)
			end
			return recipient_has_room
		end
		
		def give(giver, recipient)
			item.carrier = recipient
			Entity::Message.new(
			{
				characters: [giver.id],
				type: MessageType::GENERIC,
				message: "You give your #{item.name} to #{recipient.name_link}."
			}).save
			Entity::Message.new(
			{
				characters: [recipient.id],
				type: MessageType::GENERIC,
				message: "#{giver.name_link} gave you #{giver.pronoun :his} #{item.name}."})
			.save
		end
		
		def self.status_type_id
			@@status_type_id ||= Entity::StatusType.find_by({name: "Giveability"}).id
		end
	end
end
