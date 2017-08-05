module Effect
	class Duration

		def save_state_to_datatable
			{type: 'Duration', select_1: @type, text_3: @max_duration}
		end

		def self.save_state_from_datatable(parent, table)
			['Duration', table[:text_3].to_i, table[:select_1].to_sym]
		end

		def self.datatable_define
			Effect::Base.datatable_setup({
					                             show: ['select_1', 'text_3'],
					                             labels: {select_1: 'Interval', text_3: 'Duration'},
					                             options: {select_1: StatusTick::LIST},
					                             values: {select_1: StatusTick::STATUS, text_3: 1}
			                             })
		end

	end
end