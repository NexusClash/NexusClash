module Effect
	class SkillPrerequisite

		def save_state_to_datatable
			{type: 'SkillPrerequisite', text_1: @link.id}
		end

		def self.save_state_from_datatable(parent, table)
			['SkillPrerequisite', table[:text_1].to_i]
		end

		def self.datatable_define
			Effect::Base.datatable_setup({
					                             show: ['text_1'],
					                             labels: {text_1: 'Prerequisite Status Effect ID'},
					                             options: {},
					                             values: {text_1: ''}
			                             })
		end

	end
end