module Effect
	class CastSpells

		attr_reader :parent

		def initialize(parent)
			@parent = parent
			unserialise
		end

		def unserialise
			character = @parent
			character = @parent.stateful if character.is_a? Entity::Status
			character = @parent.carrier if character.is_a? Entity::Item
			character.cast_spells = true if character.respond_to? :cast_spells=
		end

		def describe
			'Allows character to learn and cast spells from scrolls.'
		end

		def save_state
			['CastSpells']
		end
	end
end
