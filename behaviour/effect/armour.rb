module Effect
	class Armour < Defence

		def equipped?
			@parent.get_tag :equipped
		end

		def alter_damage_intent(intent)
			intent.debug "#{name} #{equipped? ? 'is' : 'isn\'t'} equipped."
			super if equipped?
		end

		def save_state
			state = super
			state[0] = 'Armour'
			state
		end

	end
end