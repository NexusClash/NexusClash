module Effect
	class Armour < Defence

		def equipped?
			@parent.carrier.get_tag :equipped
		end

		def alter_damage_intent(intent)
			super if equipped?
		end

		def save_state
			state = super
			state[0] = 'Armour'
			state
		end

	end
end