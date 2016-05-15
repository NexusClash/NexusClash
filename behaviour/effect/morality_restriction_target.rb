module Effect
	class MoralityRestrictionTarget < Effect::MoralityRestriction

		def initialize(parent, min, max)
			super parent, min, max
		end

		def learn_intent_callback(action, intent)
			# Nullify the check since it doesn't apply to target restrictions
		end

		def morality_check(action, intent)
			if action == :possible?
				entity = intent.entity
				entity = intent.target_entity if @type == :target && entity.respond_to?(:target_entity)
				text  =  "Morality check - #{entity.mo} needs to be between #{@mo_min} and #{@mo_max}"
				intent.debug text
				return entity.mo >= @mo_min * 10 && entity.mo <= @mo_max * 10
			end
		end

		def describe
			"Target's Morality must be #{@mo_min} - #{@mo_max}"
		end

	end
end