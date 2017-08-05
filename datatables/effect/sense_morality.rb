module Effect
	class SenseMorality

		def save_state_to_datatable
			{type: 'SenseMorality'}
		end

		def self.save_state_from_datatable(parent, table)
			['SenseMorality']
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