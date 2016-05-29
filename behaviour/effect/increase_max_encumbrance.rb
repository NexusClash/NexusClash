module Effect
	class IncreaseMaxEncumbrance


		attr_reader :parent
		attr_reader :amount

		def initialize(parent, amount)
			@parent = parent
			@amount = amount
			unserialise
		end

		def unserialise
			character = @parent
			character = @parent.stateful if character.is_a? Entity::Status
			character = @parent.carrier if character.is_a? Entity::Item
			if character.is_a? Entity::Character
				character.weight_max += amount
				character.broadcast BroadcastScope::SELF, {packets:[{type: 'inventory', weight_max: character.weight_max, list:'add', items: []}]}.to_json
			end
		end

			def describe
			"Increases maximum encumbrance by #{amount}."
		end

		def save_state
			['IncreaseMaxEncumbrance', amount]
		end
	end
end