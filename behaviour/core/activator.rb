module Behaviour
	module Activator
		def use_item_self(item, status_id)

			uses = item.activated_uses

			unless uses.has_key? status_id
				Entity::Message.new({characters: [self.id], message: 'Unable to find that use!', type: MessageType::FAILED})
				return
			end
			if self.respond_to?(:weight) && self.respond_to?(:weight_max) &&  self.weight > self.weight_max
				Entity::Message.send_transient([self.id],'You are carrying too much weight to do this!', MessageType::FAILED)
				return
			end

			activation = uses[status_id]
			activation.realise
		end
	end
end