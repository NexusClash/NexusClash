module Effect
	class DamageReducesDuration

		def save_state_to_datatable
			{type: 'DamageReducesDuration', text_1: constant_reduction, text_2: damage_multiplier, text_3: damage_divider}
		end

		def self.save_state_from_datatable(parent, table)
			['DamageReducesDuration', table[:text_1].to_i, table[:text_2].to_i, table[:text_3].to_i]
		end

		def self.datatable_define
			Effect::Base.datatable_setup({
         show: ['text_1', 'text_2', 'text_3'],
         labels: {text_1: 'Base Reduction', text_2: 'Damage Reduction Multiplier', text_3: 'Damage Reduction Divider'},
         values: {text_1: 0, text_2: 1, text_3: 1}
     })
		end

	end
end