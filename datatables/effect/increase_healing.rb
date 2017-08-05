module Effect
	class IncreaseHealing

		def save_state_to_datatable
			{type: 'IncreaseHealing', select_1: @affect_self ? :yes : :no, text_2: @amount}
		end

		def self.save_state_from_datatable(parent, table)
			['IncreaseHealing', table[:select_1].to_sym == :yes, table[:text_2].to_i]
		end

		def self.datatable_define
			Effect::Base.datatable_setup({
					show: ['select_1',  'text_2'],
					labels: {select_1: 'Affect Self-Healing?', text_2: 'Healing Increase'},
			    options: {select_1: [:yes, :no]},
			    values: {select_1: :yes, text_2: 0}
			})
		end

	end
end