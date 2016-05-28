module Effect
	class IncreaseHealing

		attr_reader :parent

		def initialize(parent, affect_self, amount)
			@parent = parent
			@amount = amount.to_i
			@affect_self = affect_self
		end

		def increase_healing(source, target, heal_amount)
			return 0 if @affect_self == false && source == target
			@amount
		end

		def describe
			"Increase healing effects by #{@amount}"
		end

		def save_state
			['IncreaseHealing', @affect_self, @amount]
		end
	end
end