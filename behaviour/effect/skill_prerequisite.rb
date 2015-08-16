module Effect
	class SkillPrerequisite

		attr_reader :parent
		attr_reader :link

		def initialize(parent, prerequisite)
			@parent = parent
			@link = Entity::StatusType.find prerequisite.to_i
		end

		def describe
			case @link.family
				when :class
					"Must be a #{@link.name}."
				when :skill
					"Must know #{@link.name}."
				else
					"Must have the #{@link.name} status effect."
			end
		end

		def save_state
			['SkillPrerequisite', @link.id]
		end

	end
end