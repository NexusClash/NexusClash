module Effect
	class SeeHitPoints


		attr_reader :parent

		def initialize(parent)
			@parent = parent
			unserialise
		end

		def unserialise
			character = @parent
			character = @parent.stateful if character.is_a? Entity::Status
			character = @parent.carrier if character.is_a? Entity::Item
			character.sense_health = true if character.respond_to? :sense_health=
		end

		def describe
			'Allows character to see exact HP values.'
		end

		def save_state
			['SeeHitPoints']
		end
	end
end