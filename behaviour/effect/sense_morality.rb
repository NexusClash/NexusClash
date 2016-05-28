module Effect
	class SenseMorality


		attr_reader :parent

		def initialize(parent)
			@parent = parent
			unserialise
		end

		def unserialise
			character = @parent
			character = @parent.stateful if character.is_a? Entity::Status
			character = @parent.carrier if character.is_a? Entity::Item
			character.sense_morality = true if character.respond_to? :sense_morality=
		end

		def describe
			'Allows character to see Morality.'
		end

		def save_state
			['SenseMorality']
		end
	end
end