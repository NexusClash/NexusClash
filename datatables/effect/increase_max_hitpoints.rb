module Effect
	class IncreaseMaxHitpoints

		def save_state_to_datatable
			{type: 'IncreaseMaxHitpoints', text_1: @amount}
		end

		def self.save_state_from_datatable(parent, table)
			['IncreaseMaxHitpoints', table[:text_1].to_i]
		end

		def self.datatable_define
			Effect::Base.datatable_setup({
					show: ['text_1'],
					labels: {text_1: 'Max Hitpoints Increase'},
			    values: {text_1: 0}
			})
		end

	end
end