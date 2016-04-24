module Effect
	class ClassTier

		attr_reader :parent
		attr_reader :tier

		def initialize(parent, tier)
			@parent = parent
			@tier = tier
		end

		def describe
			"#{@parent.name} is a tier #{@tier} class"
		end

		def learn_intent_callback(action, intent)
			if action == :possible?
				# Check minimum level
				return false if intent.entity.level < (@tier - 1) * 10
				# Check for already learnt class of same tier
				intent.entity.statuses.each do |status|
					if status.family == :class
						status.effects.each do |effect|
							if effect.is_a? Effect::ClassTier
								return false if effect.tier == @tier
							end
						end
					end
				end
				return true
			end
		end

		def save_state
			['ClassTier', @tier]
		end

	end
end