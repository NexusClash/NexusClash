module Effect
	class Weapon

		attr_reader :family
		attr_reader :hit_chance
		attr_reader :damage_type
		attr_reader :damage
		attr_reader :name
		attr_accessor :parent
		attr_reader :costs
		attr_reader :armour_pierce

		def initialize(parent, family, hit_chance, damage_type, damage, name = nil, armour_pierce = 0)
			@costs = {ap: 1}
			@parent = parent
			@family = family.to_sym
			@hit_chance = hit_chance.to_i
			@damage_type = damage_type.to_sym
			@damage = damage
			@armour_pierce = armour_pierce
			if name === nil
				@name = parent.name
			else
				@name = name
			end
		end

		def weapon_intent(intent)
			intent.weapon = self
			return intent
		end

		def describe
			"#{@name.to_s} is a #{family.to_s} weapon with a base hit chance of #{@hit_chance.to_s}% which deals #{@damage.to_s} #{@damage_type.to_s} damage on hit."
		end

		def save_state
			if @name == parent.name then
				['Weapon', @family, @hit_chance, @damage_type, @damage, nil, @armour_pierce]
			else
				['Weapon', @family, @hit_chance, @damage_type, @damage, @name, @armour_pierce]
			end
		end

	end
end