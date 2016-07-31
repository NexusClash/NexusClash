module Effect
	class SkillPurchasable


		def save_state_to_datatable
			{type: 'SkillPurchasable', text_1: @cp_cost}
		end

		def self.save_state_from_datatable(parent, table)
			['SkillPurchasable', table[:text_1].to_i]
		end

		def self.datatable_define
			Effect::Base.datatable_setup({
					                             show: ['text_1'],
					                             labels: {text_1: 'CP Cost'},
					                             options: {},
					                             values: {text_1: '0'}
			                             })
		end

	end
end