module Effect
	class SpellAttack

		attr_reader :family
		attr_reader :hit_chance
		attr_reader :damage_type
		attr_reader :damage
		attr_reader :name
		attr_reader :parent
		attr_reader :costs
		attr_reader :armour_pierce

		def initialize(parent, damage_type)
			@parent = parent
			@name = parent.name
			@hit_chance = 100
			@armour_pierce = 0
			@damage = 0
			@damage_type = damage_type
			@family = family_from_damage_type

			# family-based attributes:
			@damage_formula = damage_formula_from_family
			@mp_cost = mp_cost_from_family
			@costs = {mp: @mp_cost}
		end

		def weapon_intent(intent)
			intent.weapon = self
			intent.add_cost :spell_damage, self.method(:roll_spell_damage)
			intent.damage_description = @damage_formula
			return intent
		end

		def possible?(intent)
			@possible ||= intent.entity.cast_spells
		end

		def roll_spell_damage(action, intent)
			return self.possible?(intent) if action == :possible?
			casts_at_penalty = !intent.entity.casts_at_normal_damage
			dice, sides = @damage_formula.split('d').map(&:strip).map(&:to_i)
			dice += 1 if casts_at_penalty

			rolls = self.roll(dice, sides)
			intent.debug "rolled #{rolls.join ', '}"

			if casts_at_penalty
				highest_die = rolls.max
				rolls.delete_at(rolls.find_index(highest_die))
				intent.debug "total after dropping a #{highest_die}: #{rolls.sum}"
			end
			intent.damage = rolls.sum
		end

		def describe
			"#{@name.to_s} is a #{@mp_cost.to_s} #{@family.to_s} spell that hits for #{@damage_formula.to_s} #{@damage_type.to_s}."
		end

		def save_state
			['SpellAttack', @damage_type]
		end

		def roll dice, sides
			dice.times.map{1 + rand(sides)}
		end

		def family_from_damage_type
			case @damage_type
				when /(impact|piercing|slashing)/ then :mundage
				when /(fire|cold|electric)/ then :elemental
				when /(acid|radiant|necrotic)/ then :exotic
			end
		end

		def mp_cost_from_family
			case @family
				when :mundage then 1
				when :elemental then 2
				when :exotic then 3
			end
		end

		def damage_formula_from_family
			case @family
				when :mundage then "2d4"
				when :elemental then "2d5"
				when :exotic then "2d5"
			end
		end
	end
end
