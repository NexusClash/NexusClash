module Effect
	class BloodTaste

		attr_reader :amount

		def initialize(parent, amount)
			@parent = parent
			@amount = amount
		end

		def intent_combat_hook(intent, step, pov)
			if step == :took_damage && pov == :attacker
				heal = amount
				heal = intent.defend.damage_taken if heal > intent.defend.damage_taken
				heal = intent.attack.entity.hp_max - intent.attack.entity.hp if intent.attack.entity.hp_max - intent.attack.entity.hp < heal
				if heal > 0
					intent.attack.entity.hp += heal
					intent.attack.append_message "You gain #{amount} HP from #{@parent.name}.", :attacker
				end
			end
		end

		def describe
			"#{@parent.name} heals you for up to #{amount} HP per hit"
		end

		def save_state
			['BloodTaste', amount]
		end
	end
end