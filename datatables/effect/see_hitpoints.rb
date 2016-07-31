module Effect
	class SeeHitPoints

		def save_state_to_datatable
			{type: 'SeeHitPoints'}
		end

		def self.save_state_from_datatable(parent, table)
			['SeeHitPoints']
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