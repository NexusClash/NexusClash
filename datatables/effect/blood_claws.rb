module Effect
	class BloodClaws

		def save_state_to_datatable
			{type: 'BloodClaws', text_1: @base_damage}
		end

		def self.save_state_from_datatable(parent, table)
			['BloodClaws', table[:text_1].to_i]
		end

		def self.datatable_define
			Effect::Base.datatable_setup({
         show: ['text_1'],
         labels: {text_1: 'Base Damage'},
         values: {text_1: 6}
     })
		end

	end
end