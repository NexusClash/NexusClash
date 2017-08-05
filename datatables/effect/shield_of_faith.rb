module Effect
	class ShieldOfFaith

		def save_state_to_datatable
			{type: 'ShieldOfFaith', text_1: damage_threshold,  text_2: charges}
		end

		def self.save_state_from_datatable(parent, table)
				['ShieldOfFaith', table[:text_1].to_i, table[:text_2].to_i]
		end

		def self.datatable_define
			Effect::Base.datatable_setup({
         show: ['text_1', 'text_2'],
         labels: {text_1: 'Damage Threshold', text_2: 'Charges'},
         values: {text_1: 10, text_2: 1}
     })
		end

	end
end