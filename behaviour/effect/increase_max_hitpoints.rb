module Effect
	class IncreaseMaxHitpoints


		attr_reader :parent
		attr_reader :amount

		def initialize(parent, amount)
			@parent = parent
			@amount = amount
			@applied = false
			unserialise
		end

		def unserialise
			character = @parent
			character = @parent.stateful if character.is_a? Entity::Status
			character = @parent.carrier if character.is_a? Entity::Item
			if @applied === false && character.is_a?(Entity::Character)
				@applied = true
				character.hp_max_mod += amount
				character.broadcast_self BroadcastScope::TILE
			end
		end

			def describe
			"Increases maximum HP by #{amount}."
		end

		def save_state
			['IncreaseMaxHitpoints', amount]
		end
	end
end