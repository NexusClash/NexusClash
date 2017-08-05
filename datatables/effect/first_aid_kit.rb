module Effect
	class FirstAidKit

		def save_state_to_datatable
			{type: 'FirstAidKit', text_1: @name, text_2: @amount}
		end

		def self.save_state_from_datatable(parent, table)
			['FirstAidKit', table[:text_1], table[:text_2].to_i]
		end

		def self.datatable_define
			Effect::Base.datatable_setup({
					show: ['text_1',  'text_2'],
					labels: {text_1: 'Name', text_2: 'Amount Healed'},
			    values: {text_1: 'First Aid Kit', text_2: 5}
			})
		end

	end
end