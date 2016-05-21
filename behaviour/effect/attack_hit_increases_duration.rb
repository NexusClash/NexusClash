module Effect
	class AttackHitIncreasesDuration

		attr_reader :parent
		attr_reader :amount

		def initialize(parent, amount)
			@parent = parent
			@amount = amount
		end

		def intent_combat_hook(intent, step, pov)
			if step == :attack_hit && pov == :attacker
				duration = @parent.get_tag :duration
				duration += amount
				@parent.set_tag :duration, duration
			end
		end

		def describe
			"Successful attacks increase duration of #{@parent.name} by #{amount}."
		end

		def save_state
			['AttackHitIncreasesDuration']
		end
	end
end