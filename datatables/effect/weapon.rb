module Effect
	class Weapon

		def save_state_to_datatable
			{type: 'Weapon', select_1: @family, text_1: @hit_chance, select_2: @damage_type, text_2: @damage, text_3: @name, text_4: @armour_pierce}
		end

		def self.save_state_from_datatable(parent, table)
			if table[:text_3] == '' || (parent.respond_to?(:name) && table[:text_3] == parent.name)
				['Weapon', table[:select_1].to_sym, table[:text_1].to_i, table[:select_2].to_sym, table[:text_2].to_i, nil, table[:text_4].to_i]
			else
				['Weapon', table[:select_1].to_sym, table[:text_1].to_i, table[:select_2].to_sym, table[:text_2].to_i, table[:text_3], table[:text_4].to_i]
			end
		end

		def self.datatable_define
			Effect::Base.datatable_setup({
         show: ['select_1', 'text_1', 'select_2', 'text_2', 'text_3', 'text_4'],
         labels: {select_1: 'Family', text_1: 'Hit %', select_2: 'Damage Type', text_2: 'Damage', text_3: 'Name', text_4: 'Armour Piercing'},
         options: {select_1: AttackFamily::LIST, select_2: DamageType::LIST},
         values: {select_1: :melee, text_1: 10, select_2: :slashing, text_2: 1, text_3: '', text_4: 0}
     })
		end

	end
end