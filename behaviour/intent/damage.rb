module Intent
	class Damage
		attr_accessor :hooks

		def initialize(entity)
			@entity = entity
			@soak_base = Hash.new{|_,_| 0}
			@soak_bonus = Hash.new{|_,_| 0}
			@resist_base = Hash.new{|_,_| 0}
			@resist_bonus = Hash.new{|_,_| 0}
			@avoidance = Hash.new{|_,_| 0}
			@lazy_loaded = false
			@hooks = Array.new
			@post_soak_multiplier = 1
		end

		attr_accessor :post_soak_multiplier

		# Deal damage with soak
		def deal_damage(damage, type, source = nil, armour_pierce = 0)
			damage_taken = deal_damage? damage, type, source, armour_pierce
			Entity::Status.tick @entity, StatusTick::DAMAGE_TAKEN, damage, type, source
			@entity.hp = @entity.hp - damage_taken
			return damage_taken
		end

		def deal_damage?(damage, type, source = nil, armour_pierce = 0)
			lazy_load
			soak = soak?(type)
			if soak > armour_pierce
				soak -= armour_pierce
			else
				soak = 0 if soak > 0
			end
			damage_taken = damage - soak
			damage_taken = 1 if damage > 0 && damage_taken < 1 # Damage floor
			damage_taken = damage_taken.to_f * (100 - resist?(type)) / 100
			if damage_taken.modulo(1).round(2) == 0.50 # If its about half, round up rather than down
				damage_taken = damage_taken.truncate + 1
			else
				damage_taken = damage_taken.round
			end
			@soaked = damage - damage_taken
			(damage_taken.to_f * post_soak_multiplier).floor
		end

		def soaked
			@soaked
		end

		# Deal damage, no soak
		def deal_damage!(damage)
			@entity.hp = @entity.hp - damage
			return damage
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