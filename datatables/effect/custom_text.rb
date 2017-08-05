module Effect
	class CustomText

		def save_state_to_datatable
			{type: 'CustomText', text_1: @text}
		end

		def self.save_state_from_datatable(parent, table)
			['CustomText', table[:text_1]]
		end

		def self.datatable_define
			Effect::Base.datatable_setup({
					show: ['text_1'],
					labels: {text_1: 'Text'},
			    options: {},
			    values: {text_1:''}
			})
		end

	end
end