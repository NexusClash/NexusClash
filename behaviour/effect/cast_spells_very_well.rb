module Effect
	class CastSpellsVeryWell

		attr_reader :parent

		def initialize(parent)
			@parent = parent
			unserialise
		end

		def unserialise
			character = @parent
			character = @parent.stateful if character.is_a? Entity::Status
			character = @parent.carrier if character.is_a? Entity::Item
			character.casts_with_bonus_damage = true if character.respond_to? :casts_with_bonus_damage=
		end

		def describe
			'Combat spells roll an extra die and drop the lowest.'
		end

		def save_state
			['CastSpellsVeryWell']
		end
	end
end
