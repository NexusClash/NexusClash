module Effect
	class AttackHitIncreasesDuration

		def save_state_to_datatable
			{type: 'AttackHitIncreasesDuration', text_1: amount}
		end

		def self.save_state_from_datatable(parent, table)
			['AttackHitIncreasesDuration', table[:text_1].to_i]
		end

		def self.datatable_define
			Effect::Base.datatable_setup({
         show: ['text_1'],
         labels: {text_1: 'Duration Increase'},
         values: {text_1: 1}
     })
		end

	end
end