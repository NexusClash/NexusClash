module Effect
	class ActivatedTarget

		def save_state_to_datatable
			{type: 'ActivatedTarget', text_2: @costs[:ap], text_3: @costs[:mp], text_1: @name}
		end

		def self.save_state_from_datatable(parent, table)
			if table[:text_1] != ''
				['ActivatedTarget', {ap: table[:text_2].to_i, mp: table[:text_3].to_i}, table[:text_1]]
			else
				['ActivatedTarget', {ap: table[:text_2].to_i, mp: table[:text_3].to_i}]
			end
		end

		def self.datatable_define
			Effect::Base.datatable_setup({
					show: ['text_1', 'text_2', 'text_3'],
					labels: {text_1: 'Name', text_2: 'AP', text_3: 'MP'},
			    options: {},
			    values: {text_1: '', text_2: 1, text_3: ''}
			})
		end

	end
end