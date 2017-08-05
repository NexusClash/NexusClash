module Effect
	class GrantStatus

		def save_state_to_datatable
			{type: 'GrantStatus', select_1: @interval, select_2: @status, select_3: @target, select_4: @overlap}
		end

		def self.save_state_from_datatable(parent, table)
			['GrantStatus', table[:select_1], table[:select_2].to_i, table[:select_3].to_sym, table[:select_4].to_sym]
		end

		def self.datatable_define

			statuses = Hash.new

			Entity::StatusType.types.each do |type|
				statuses[type.id] = type.name
			end

			statuses = statuses.sort_by &:last

			Effect::Base.datatable_setup({
					show: ['select_1', 'select_2', 'select_3', 'select_4'],
					labels: {select_1: 'Interval', select_2: 'Status', select_3: 'Target', select_4: 'Overlap Behaviour'},
			    options: {select_1: StatusTick::LIST, select_2: statuses, select_3: [:character, :item, :tile], select_4: [:extend, :ignore, :overwrite, :refresh, :stack]},
			    values: {select_1: :ap, select_2: 1, select_3: :character, select_4: :ignore}
			})
		end

	end
end