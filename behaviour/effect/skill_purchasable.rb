module Effect
	class SkillPurchasable

		attr_reader :parent
		attr_reader :cp_cost

		def initialize(parent, cost)
			@parent = parent
			@cp_cost = cost
		end

		def describe
			if @parent.respond_to? :name
				"Learning #{@parent.name} costs #{@cp_cost.to_s} CP."
			else
				"Learning this skill costs #{@cp_cost.to_s} CP."
			end
		end

		#deprecated
		def purchase_skill?(target)
			if target.respond_to? :cp && target.cp >= @cp_cost
				true
			else
				false
			end
		end

		#deprecated
		def purchase_skill!(target)
			if target.respond_to? :cp && target.cp >= @cp_cost
				target.cp -= @cp_cost
				true
			else
				false
			end
		end

		def save_state
			['SkillPurchasable', @cp_cost]
		end


	end
end