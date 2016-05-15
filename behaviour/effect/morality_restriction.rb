module Effect
	class MoralityRestriction

		attr_reader :parent
		attr_reader :mo_min, :mo_max

		def initialize(parent, min, max)
			@parent = parent
			@mo_min = min
			@mo_max = max
		end

		def learn_intent_callback(action, intent)
			intent.entity.mo >= @mo_min * 10 && intent.entity.mo <= @mo_max * 10 if action == :possible?
		end

		def activate_self_intent(intent)
			intent.add_cost self.class.name.to_sym, self.method(:morality_check)
		end

		def activate_target_intent(intent)
			intent.add_cost self.class.name.to_sym, self.method(:morality_check)
		end

		def morality_check(action, intent)
			if action == :possible?
				entity = intent.entity
				text  =  "Morality check - #{entity.mo} needs to be between #{@mo_min} and #{@mo_max}"
				intent.debug text
				return entity.mo >= @mo_min * 10 && entity.mo <= @mo_max * 10
			end
		end

		def describe
			"Morality must be #{@mo_min} - #{@mo_max}"
		end

		def save_state
			[self.class.name, @mo_min, @mo_max]
		end

	end
end