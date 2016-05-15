module Effect
	class AlonaiAegisBuff

		def initialize(parent, costs = {ap: 1}, name = 'Alonai\'s Aegis')
			super parent, costs, name, [Entity::Character]
		end

		def can_target?(tar)
			tar.is_a? Entity::Character
		end

		def activate_self_intent(intent)
			intent.name = name
			@costs.each do |cost, delta|
				intent.add_cost cost, delta
			end
		end

		def activate_target_intent(intent)
			intent.name = name
			@costs.each do |cost, delta|
				intent.add_cost cost, delta
			end
		end

		def describe
			"Alonai's Aegis is an activated ability, costing #{@costs[:ap].to_s} AP + #{@costs[:mp].to_s} MP."
		end

		def save_state
			if @name === @parent.name
				['AlonaiAegis', @costs]
			else
				['AlonaiAegis', @costs, @name]
			end
		end

	end
end