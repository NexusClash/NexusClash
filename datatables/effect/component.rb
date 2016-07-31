module Effect
	class Component

		def save_state_to_datatable
			{type: 'Component', text_1: @name}
		end

		def self.save_state_from_datatable(parent, table)
			['Component', table[:text_1]]
		end

		def self.datatable_define
			Effect::Base.datatable_setup({
					                             show: ['text_1'],
					                             labels: {text_1: 'Component Name'},
					                             options: {},
					                             values: {text_1:''}
			                             })
		end

	end
end