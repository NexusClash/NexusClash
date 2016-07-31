module Effect
	class Regen

		def save_state_to_datatable
			{type: 'Regen', select_1: @interval, select_2: @type, text_3: @amount}
		end

		def self.save_state_from_datatable(parent, table)
			['Regen', table[:select_1], table[:select_2], table[:text_3].to_i]
		end

		def self.datatable_define
			Effect::Base.datatable_setup({
					show: ['select_1', 'select_2', 'text_3'],
					labels: {select_1: 'Interval', select_2: 'Type', text_3: 'Amount'},
			    options: {select_1: StatusTick::LIST, select_2: [:ap, :hp, :mo, :mp, :xp]},
			    values: {select_1: :ap, select_2: :ap, text_3: 1}
			})
		end

	end
end