module Effect
	class TogglePower

		def save_state_to_datatable
			{type: 'TogglePower'}
		end

		def self.save_state_from_datatable(parent, table)
			['TogglePower']
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