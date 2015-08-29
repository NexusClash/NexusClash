module Behaviour
	module Usable
		def activated_uses

			character = nil
			if self.is_a? Entity::Character
				character = self
				items = character.items
			end
			if self.is_a? Entity::Item
				character = self.carrier
				items = [self]
			end

			intents = {}

			#Gather activated uses
			items.each do |item|
				item.statuses.each do |status|
					status.effects.each do |effect|
						if effect.respond_to?(:activate_self_intent)
							intents[status.object_id] = Intent::ActivateItemSelf.new character, item, effect
						end
					end
				end
				item.type_statuses.each do |status|
					status.effects.each do |effect|
						if effect.respond_to?(:activate_self_intent)
							intents[status.object_id] = Intent::ActivateItemSelf.new character, item, effect
						end
					end
				end
			end

			return intents

		end

	end
end