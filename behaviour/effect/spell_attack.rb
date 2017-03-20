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
			@family = :magical
			@spell_category = spell_category_from_damage_type

			# family-based attributes:
			@damage_formula = damage_formula_from_spell_category
			@mp_cost = mp_cost_from_spell_category
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

		# to allow override to use super
		def name
			@name
		end

		def roll_spell_damage(action, intent)
			return self.possible?(intent) if action == :possible?
			casts_at_penalty = !intent.entity.casts_at_normal_damage
			casts_with_bonus = intent.entity.casts_with_bonus_damage
			dice, sides = @damage_formula.split('d').map(&:strip).map(&:to_i)
			dice += 1 if casts_at_penalty or casts_with_bonus

			rolls = self.roll(dice, sides)
			intent.debug "rolled #{rolls.join ', '}"

			if casts_at_penalty
				intent.append_message(" Your effectiveness is somewhat limited by your lack of skill.")
				highest_die = rolls.max
				rolls.delete_at(rolls.find_index(highest_die))
				intent.debug "total after dropping a #{highest_die}: #{rolls.sum}"
			end
			if casts_with_bonus
				intent.append_message(" Your effectiveness is somewhat enahnced by your exceptional skill.")
				lowest_die = rolls.min
				rolls.delete_at(rolls.find_index(lowest_die))
				intent.debug "total after dropping a #{lowest_die}: #{rolls.sum}"
			end
			intent.damage = rolls.sum
			apply_special_effects(intent)
		end

		def apply_special_effects(intent)
			status_roll = 1 #rand(1..100)
			is_success = status_roll <= special_effect_chance_from_damage_type
			intent.debug "status roll was #{status_roll} needed #{special_effect_chance_from_damage_type}. roll was #{is_success ? '' : 'un'}successful"
			return unless is_success
			special_effect_status_from_damage_type(intent)
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

		def spell_category_from_damage_type
			case @damage_type
				when /(impact|piercing|slashing)/ then :mundane
				when /(fire|cold|electric)/ then :elemental
				when /(acid|radiant|necrotic)/ then :exotic
			end
		end

		def mp_cost_from_spell_category
			case @spell_category
				when :mundane then 1
				when :elemental then 2
				when :exotic then 3
			end
		end

		def damage_formula_from_spell_category
			case @spell_category
				when :mundane then "2d4"
				when :elemental then "2d5"
				when :exotic then "2d6"
			end
		end

		def special_effect_chance_from_damage_type
			case @damage_type.to_sym
				when :impact then 10
				when :piercing then 5
				when :slashing then 20
				when :fire then 10
				when :cold then 10
				when :electric then 15
				else 0
			end
		end

		def special_effect_status_from_damage_type(intent)
			method_to_call = "apply_#{@damage_type}_special_effect"
			self.send(method_to_call, intent) if self.respond_to?(method_to_call)
		end

		def	apply_impact_special_effect(intent)
			intent.debug("double damage vs. forts is not implemented")
		end

		def	apply_piercing_special_effect(intent)
			intent.debug("bleeding is not implemented") #add_status(victim, 192)
		end

		def	apply_slashing_special_effect(intent)
			intent.damage += 4
			intent.append_message(" #{intent.target.name} was extraordinarily flayed in this attack.")
		end

		def	apply_fire_special_effect(intent)
			intent.debug("burning is not implemented") # add_status(victim, 191)
		end

		def	apply_cold_special_effect(intent)
			intent.debug("freezing is not implemented") # add_status(victim, 193)
		end

		def	apply_electric_special_effect(intent)
			intent.debug("double damage vs. forts is not implemented")
		end

		def add_status victim, status_type_id
			victim.statuses << Entity::Status.source_from(status_type_id)
		end
	end
end
