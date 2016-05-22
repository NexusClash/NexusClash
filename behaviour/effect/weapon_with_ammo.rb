module Effect
	class WeaponWithAmmo < Weapon

		attr_reader :empty_message
		attr_reader :ammo_cost
		attr_reader :armour_pierce

		def initialize(parent, family, hit_chance, damage_type, damage, ammo_cost, empty_message, name = nil, armour_pierce = 0)
			super parent, family, hit_chance, damage_type, damage, name
			@empty_message = empty_message
			@ammo_cost = ammo_cost.to_i
			@armour_pierce = armour_pierce
			@costs[:ammo] = self.method(:ammo_callback)
		end

		def ammo_callback(action, intent)
			weapon_entity = @parent.parent
			case action
				when :possible?
					amount_ammo = weapon_entity.get_tag :ammo if weapon_entity.respond_to? :get_tag
					result = amount_ammo != nil && @ammo_cost <= amount_ammo
				when :apply_costs
					amount_ammo = weapon_entity.get_tag(:ammo) - @ammo_cost
					weapon_entity.set_tag :ammo, amount_ammo
					if amount_ammo == 0
						msg_no_ammo = Entity::Message.new({characters: [intent.entity.id], message: @empty_message, type: MessageType::AMMO_EMPTIED})
						msg_no_ammo.save
					end
					intent.entity.broadcast(BroadcastScope::SELF, {packets:[{type: 'inventory', list: 'update', items: [weapon_entity.to_h]}]}.to_json) if weapon_entity.is_a? Entity::Item
			end
			result
		end

		def describe
			"#{@name.to_s} is a #{family.to_s} weapon with a base hit chance of #{@hit_chance.to_s}% which deals #{@damage.to_s} #{@damage_type.to_s} damage on hit. Each attack uses #{@ammo_cost.to_s} ammo."
		end

		def save_state
			if @name == parent.name then
				['WeaponWithAmmo', @family, @hit_chance, @damage_type, @damage, @ammo_cost, @empty_message, nil, @armour_pierce]
			else
				['WeaponWithAmmo', @family, @hit_chance, @damage_type, @damage, @ammo_cost, @empty_message, @name, @armour_pierce]
			end
		end

	end
end