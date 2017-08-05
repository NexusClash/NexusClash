module Effect
	class MoralityRestriction

		def save_state_to_datatable
			{type: 'MoralityRestriction', text_1: @mo_min, text_2: @mo_max}
		end

		def self.save_state_from_datatable(parent, table)
			['MoralityRestriction', table[:text_1].to_i, table[:text_2].to_i]
		end

		def self.datatable_define
			Effect::Base.datatable_setup({
					                             show: ['text_1', 'text_2'],
					                             labels: {text_1: 'Minimum Morality', text_2: 'Maximum Morality'},
					                             options: {},
					                             values: {text_1: '', text_2: ''}
			                             })
		end

	end
end