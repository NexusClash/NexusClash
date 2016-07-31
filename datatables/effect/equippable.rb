module Effect
	class Equippable

		def save_state_to_datatable
			{type: 'Equippable', text_1: slot}
		end

		def self.save_state_from_datatable(parent, table)
			if table[:text_1]
				['Equippable', table[:text_1]]
			else
				['Equippable']
			end
		end

		def self.datatable_define
			Effect::Base.datatable_setup({
					                             show: ['text_1'],
					                             labels: {text_1: 'Slot'},
					                             options: {},
					                             values: {text_1:''}
			                             })
		end

	end
end