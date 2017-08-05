module Effect
	class SenseMagic

		def save_state_to_datatable
			{type: 'SenseMagic'}
		end

		def self.save_state_from_datatable(parent, table)
			['SenseMagic']
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