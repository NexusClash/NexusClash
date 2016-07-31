module Effect
	class LimitedUses

		def save_state_to_datatable
			{type: 'LimitedUses'}
		end

		def self.save_state_from_datatable(parent, table)
			['LimitedUses', 1]
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