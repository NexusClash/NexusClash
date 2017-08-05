module Effect
	class Smite

		def save_state_to_datatable
			{type: 'Smite', select_1: @damage_type, text_1: name, text_2: @costs[:ap], text_3: @costs[:mp], text_4: @damage, text_5: @hit_chance, text_6: @evil_damage, text_7: @demon_damage}
		end

		def self.save_state_from_datatable(parent, table)
				['Smite', {ap: table[:text_2].to_i, mp: table[:text_3].to_i}, table[:text_1], table[:text_4].to_i, table[:select_1], table[:text_5].to_i, table[:text_6].to_i, table[:text_7].to_i]
		end

		def self.datatable_define
			dmg = DamageType::LIST.clone
			dmg = dmg.unshift :none

			Effect::Base.datatable_setup({
         show: ['select_1', 'text_1', 'text_2', 'text_3', 'text_4', 'text_5', 'text_6', 'text_7'],
         labels: {select_1: 'Damage Type Change', text_1: 'Name', text_2: 'AP Cost', text_3: 'MP Cost', text_5: 'Hit % +/-', text_4: 'Damage +/-', text_6: 'Evil Damage +/-', text_7: 'Demon Damage +/-'},
         options: {select_1: dmg},
         values: {select_1: :none, text_1: '', text_2: 0, text_3: 0, text_4: 0, text_5: 0, text_6: 0, text_7: 0}
     })
		end

	end
end