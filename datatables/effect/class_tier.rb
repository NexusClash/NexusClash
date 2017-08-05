module Effect
	class ClassTier

		def save_state_to_datatable
			{type: 'ClassTier', text_1: @tier}
		end

		def self.save_state_from_datatable(parent, table)
			['ClassTier', table[:text_1].to_i]
		end

		def self.datatable_define
			Effect::Base.datatable_setup({
					                             show: ['text_1'],
					                             labels: {text_1: 'Class Tier'},
					                             options: {},
					                             values: {text_1: ''}
			                             })
		end

	end
end