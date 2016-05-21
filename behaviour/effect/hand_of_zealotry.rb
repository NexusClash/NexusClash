module Effect
	class HandOfZealotry

		attr_reader :parent

		def initialize(parent)
			@parent = parent
		end

		def describe
			'You no longer lose morality for attacking / killing Neutral characters'
		end

		def intent_combat_hook(intent, step, pov)
			# Doing stuff to neutral characters incurs no MO hit
			intent.mo_delta = 0 if step == :took_damage && pov == :attacker && intent.attack.target.alignment == :neutral
		end

		def save_state
			['HandOfZealotry']
		end
	end
end