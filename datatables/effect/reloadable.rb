module Effect
	class Reloadable

		def save_state_to_datatable
			{type: 'Reloadable', text_1: @ammo_type, text_2: @capacity}
		end

		def self.save_state_from_datatable(parent, table)
			['Reloadable', table[:text_1], table[:text_2].to_i]
		end

		def self.datatable_define
			Effect::Base.datatable_setup({
					                             show: ['text_1', 'text_2'],
					                             labels: {text_1: 'Ammo Type', text_2: 'Capacity'},
					                             options: {},
					                             values: {text_1:'', text_2:0}
			                             })
		end

	end
end