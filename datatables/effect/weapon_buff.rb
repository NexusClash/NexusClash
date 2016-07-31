module Effect
	class WeaponBuff

		def save_state_to_datatable
			{type: 'WeaponBuff', select_1: @family, text_1: @hit_chance.to_s, text_2: @damage.to_s, text_3: @name}
		end

		def self.save_state_from_datatable(parent, table)
			if table[:text_3] === nil || table[:text_3] == ''
				if table[:text_2] == 0
					if table[:text_1] == 0
						if table[:select_1] == :all
							['WeaponBuff'] #lol
						else
							['WeaponBuff', table[:select_1]]
						end
					else
						['WeaponBuff', table[:select_1], table[:text_1].to_i]
					end
				else
					['WeaponBuff', table[:select_1], table[:text_1].to_i, table[:text_2].to_i]
				end
			else
				['WeaponBuff', table[:select_1], table[:text_1].to_i, table[:text_2].to_i, table[:text_3]]
			end
		end

		def self.datatable_define
			Effect::Base.datatable_setup({
         show: ['select_1', 'text_1', 'text_2', 'text_3'],
         labels: {select_1: 'Family Filter', text_1: 'Hit % +/-', text_2: 'Damage +/-', text_3: 'Name Filter'},
         options: {select_1: AttackFamily::LIST},
         values: {select_1: :all, text_1: 0, text_2: 0, text_3: ''}
     })
		end

	end
end