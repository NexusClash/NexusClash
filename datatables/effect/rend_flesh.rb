module Effect
	class RendFlesh

		def save_state_to_datatable
			{type: 'RendFlesh'}
		end

		def self.save_state_from_datatable(parent, table)
			['RendFlesh']
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