module Effect
	class SenseMagic


		attr_reader :parent

		def initialize(parent)
			@parent = parent
			unserialise
		end

		def unserialise
			character = @parent
			character = @parent.stateful if character.is_a? Entity::Status
			character = @parent.carrier if character.is_a? Entity::Item
			character.sense_magic = true if character.respond_to? :sense_magic=
		end

			def describe
			'Allows character to see MP values.'
		end

		def save_state
			['SenseMagic']
		end
	end
end