module Effect
	class HandOfZealotry

		def save_state_to_datatable
			{type: 'HandOfZealotry'}
		end

		def self.save_state_from_datatable(parent, table)
			['HandOfZealotry']
		end

		def self.datatable_define
			Effect::Base.datatable_setup({
					                             show: [],
					                             labels: {},
					                             options: {},
					                             values: {}
			                             })
		end

	end
end