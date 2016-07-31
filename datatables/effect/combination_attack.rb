module Effect
	class CombinationAttack

		def save_state_to_datatable
			{type: 'CombinationAttack', text_1: attack_interval, text_2: base_bonus, text_3: level_mult, text_4: level_div}
		end

		def self.save_state_from_datatable(parent, table)
			['CombinationAttack', table[:text_1].to_i, table[:text_2].to_i, table[:text_3].to_i, table[:text_4].to_i]
		end

		def self.datatable_define
			Effect::Base.datatable_setup({
         show: ['text_1', 'text_2', 'text_3', 'text_4'],
         labels: {text_1: 'Combination Attack triggers on every Xth hit', text_2: 'Base Damage Bonus', text_3: 'Level Damage Multiplier', text_4: 'Level Damage Divider'},
         values: {text_1: 30, text_2: 3, text_3: 1, text_4: 4}
     })
		end

	end
end