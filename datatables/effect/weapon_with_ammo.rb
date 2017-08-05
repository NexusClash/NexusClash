module Effect
	class WeaponWithAmmo < Weapon

		def save_state_to_datatable
			{type: 'WeaponWithAmmo', select_1: @family, text_1: @hit_chance, select_2: @damage_type, text_2: @damage, text_3: @name, text_4: @ammo_cost, text_5: @empty_message, text_6: @armour_pierce}
		end

		def self.save_state_from_datatable(parent, table)
			if table[:text_3] == '' || (parent.respond_to?(:name) && table[:text_3] == parent.name)
				['WeaponWithAmmo', table[:select_1].to_sym, table[:text_1].to_i, table[:select_2].to_sym, table[:text_2].to_i, table[:text_4].to_i, table[:text_5], nil, table[:text_6].to_i]
			else
				['WeaponWithAmmo', table[:select_1].to_sym, table[:text_1].to_i, table[:select_2].to_sym, table[:text_2].to_i, table[:text_4].to_i, table[:text_5], table[:text_3], table[:text_6].to_i]
			end
		end

		def self.datatable_define
			Effect::Base.datatable_setup({
         show: ['select_1', 'text_1', 'select_2', 'text_2', 'text_3', 'text_4', 'text_5', 'text_6'],
         labels: {select_1: 'Family', text_1: 'Hit %', select_2: 'Damage Type', text_2: 'Damage', text_3: 'Name', text_4: 'Ammo Cost', text_5: 'Empty Message', text_6: 'Armour Piercing'},
         options: {select_1: AttackFamily::LIST, select_2: DamageType::LIST},
         values: {select_1: :melee, text_1: 10, select_2: :slashing, text_2: 1, text_3: '', text_4: 1, text_5: 'Your weapon has run out of ammo!', text_6: 0}
     })
		end

		def save_state
			if name == parent.name then
				['WeaponWithAmmo', @family, @hit_chance, @damage_type, @damage, @ammo_cost, @empty_message, nil, @armour_pierce]
			else
				['WeaponWithAmmo', @family, @hit_chance, @damage_type, @damage, @ammo_cost, @empty_message, @name, @armour_pierce]
			end
		end

	end
end