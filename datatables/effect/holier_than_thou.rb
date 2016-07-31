module Effect
	class HolierThanThou

		def save_state_to_datatable
			{type: 'HolierThanThou'}
		end

		def self.save_state_from_datatable(parent, table)
			['HolierThanThou']
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