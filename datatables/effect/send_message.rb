module Effect
	class SendMessage

		def save_state_to_datatable
			{type: 'SendMessage', text_1: @message, select_2: @interval, select_3: @scope}
		end

		def self.save_state_from_datatable(parent, table)
			['SendMessage', table[:text_1], table[:select_2].to_sym, table[:select_3].to_i]
		end

		def self.datatable_define
			Effect::Base.datatable_setup({
					show: ['text_1', 'select_2', 'select_3'],
					labels: {text_1: 'Message', select_2: 'Trigger Event/Interval', select_3: 'Broadcast Scope'},
			    options: {select_2: StatusTick::LIST, select_3: {self: BroadcastScope::SELF, tile: BroadcastScope::TILE}},
			    values: {select_2: StatusTick::ITEM_ACTIVATED, select_3: BroadcastScope::SELF, text_1: ''}
			})
		end

	end
end