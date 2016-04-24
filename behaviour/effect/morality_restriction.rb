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
			intent.entity.mo >= @mo_min && intent.entity.mo <= @mo_max if action == :possible?
		end

		def describe
			"Morality must be #{@mo_min} - #{@mo_max}"
		end

		def save_state
			['MoralityRestriction', @mo_min, @mo_max]
		end

	end
end