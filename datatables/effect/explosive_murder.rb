module Effect
	class ExplosiveMurder
		#death_odds, accuracy, total_dmg_level_mult
		def save_state_to_datatable
			{type: 'ExplosiveMurder', text_1: @death_odds, text_2: @accuracy, text_3: @total_dmg_level_mult}
		end

		def self.save_state_from_datatable(parent, table)
			['ExplosiveMurder', table[:text_1].to_i, table[:text_2].to_i, table[:text_3].to_i]
		end

		def self.datatable_define
			Effect::Base.datatable_setup({
					show: ['text_1', 'text_2', 'text_3'],
					labels: {text_1: 'Death Trigger Chance %', text_2: 'Accuracy %', text_3: 'Total Damage Level Multiplier'},
			    options: {},
			    values: {text_1: 50, text_2: 75, text_3: 10}
			})
		end

	end
end