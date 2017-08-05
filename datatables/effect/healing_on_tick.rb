module Effect
	class HealingOnTick

		def save_state_to_datatable
			{type: 'HealingOnTick', select_1: @interval, text_3: @amount}
		end

		def self.save_state_from_datatable(parent, table)
			['HealingOnTick', table[:select_1], table[:text_3].to_i]
		end

		def self.datatable_define
			Effect::Base.datatable_setup({
					show: ['select_1', 'text_3'],
					labels: {select_1: 'Interval', text_3: 'Amount'},
			    options: {select_1: StatusTick::LIST},
			    values: {select_1: :ap, text_3: 1}
			})
		end

	end
end