module Effect
	class SkillPrerequisite

		def save_state_to_datatable
			{type: 'SkillPrerequisite', select_1: @link.id}
		end

		def self.save_state_from_datatable(parent, table)
			['SkillPrerequisite', table[:select].to_i]
		end

		def self.datatable_define
			statuses = Hash.new

			Entity::StatusType.types.each do |type|
				statuses[type.id] = type.name
			end

			statuses = statuses.sort_by &:last

			Effect::Base.datatable_setup({
					                             show: ['select_1'],
					                             labels: {select_1: 'Prerequisite Status'},
					                             options: {select_1: statuses},
					                             values: {select_1: ''}
			                             })
		end

	end
end