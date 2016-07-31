module Effect
	class BloodTaste

		def save_state_to_datatable
			{type: 'BloodTaste', text_1: amount}
		end

		def self.save_state_from_datatable(parent, table)
				['BloodTaste', table[:text_1].to_i]
		end

		def self.datatable_define
			Effect::Base.datatable_setup({
         show: ['text_1'],
         labels: {text_1: 'Max Heal'},
         values: {text_1: 3}
     })
		end

	end
end