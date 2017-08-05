module Effect
	class SeePowerState

		def save_state_to_datatable
			{type: 'SeePowerState'}
		end

		def self.save_state_from_datatable(parent, table)
			['SeePowerState']
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