module Intent
	class Damage
		def initialize(entity)
			@entity = entity
			@soak_base = Hash.new{|_,_| 0}
			@soak_bonus = Hash.new{|_,_| 0}
			@resist_base = Hash.new{|_,_| 0}
			@resist_bonus = Hash.new{|_,_| 0}
			@avoidance = Hash.new{|_,_| 0}
			@lazy_loaded = false
		end

		# Deal damage with soak
		def deal_damage(damage, type)
			lazy_load
			damage_dealt = deal_damage?(damage, type)
			@entity.hp = @entity.hp - damage_dealt
			return damage_dealt
		end

		# Deal damage, no soak
		def deal_damage!(damage)
			@entity.hp = @entity.hp - damage
			return damage
		end

		# Check damage after soaks
		def deal_damage?(damage, type)
			lazy_load
			damage_taken = damage - soak?(type)
			damage_taken = 1 if damage > 0 && damage_taken < 1 # Damage floor
			damage_taken = damage_taken.to_f * (100 - resist?(type)) / 100
			if damage_taken.modulo(1).round(2) == 0.50 # If its about half, round up rather than down
				damage_taken = damage_taken.truncate + 1
			else
				damage_taken = damage_taken.round
			end
			return damage_taken.to_i
		end

		def add_soak(damage_type, amount, soak_type = DefenceType::BONUS_SOAK)
			@soak_base[damage_type] = [@soak_base[damage_type], amount].max if soak_type == DefenceType::BASE_SOAK
			@soak_bonus[damage_type] += amount if soak_type == DefenceType::BONUS_SOAK
		end

		def add_resist(damage_type, amount, soak_type = DefenceType::BONUS_SOAK)
			@resist_base[damage_type] = [@resist_base[damage_type], amount].max if soak_type == DefenceType::BASE_SOAK
			@resist_bonus[damage_type] += amount if soak_type == DefenceType::BONUS_SOAK
		end

		alias add_resistance add_resist

		def add_avoidance(avoidance_type, amount)
			@avoidance[avoidance_type] += amount
		end

		def avoided?
			@avoided |= rand(1..100) <= @avoidance[DefenceType::GENERIC_COMBAT_AVOIDANCE]
		end

		def attack_penalty?(attack_type)
			@avoidance[attack_type]
		end

		def soak?(type)
			@soak_base[type] + @soak_bonus[type]
		end

		def resist?(type)
			@resist_base[type] + @resist_bonus[type]
		end

		private

		def lazy_load
			unless @lazy_loaded
				@entity.each_applicable_effect do |effect|
					if effect.respond_to? :alter_damage_intent
						effect.alter_damage_intent self
					end
				end
				@lazy_loaded = true
			end
		end

	end
end