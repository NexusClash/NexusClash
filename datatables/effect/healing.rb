module Effect
	class Healing

		def save_state_to_datatable
			{type: 'Healing', select_1: @interval, text_2: @amount}
		end

		def self.save_state_from_datatable(parent, table)
			['Healing', table[:select_1], table[:text_2].to_i]
		end

		def self.datatable_define
			Effect::Base.datatable_setup({
					show: ['select_1',  'text_2'],
					labels: {select_1: 'Interval', text_2: 'Amount Healed'},
			    options: {select_1: StatusTick::LIST},
			    values: {select_1: :activated_target, text_2: 0}
			})
		end

	end
end