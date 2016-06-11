module Intent
	class Defend < Action
		def initialize(entity, damage_intent = nil)
			super entity, {encumbrance: false, status_tick: false, unhide: false, alive: false}
			if damage_intent === nil
				@damage_intent = Intent::Damage.new entity
			else
				@damage_intent = damage_intent
			end
			@original_multiplier = nil
		end

		def invulnerable=(val)
			if val
				@original_multiplier = @damage_intent.post_soak_multiplier unless @damage_intent.post_soak_multiplier == 0
				@damage_intent.post_soak_multiplier = 0
			else
				@damage_intent.post_soak_multiplier = @original_multiplier unless @original_multiplier === nil
			end
		end

		def invulnerable
			@damage_intent.post_soak_multiplier == 0
		end

		def take_hit(attack)
			@damage_taken = xp_gain =  @damage_intent.deal_damage(attack.damage, attack.damage_type, attack.entity, attack.weapon.armour_pierce)
			xp_gain += @entity.level if @entity.dead?
			attack.grant_attacker_xp xp_gain
		end

		def damage_taken(attack = nil)
			return @damage_intent.deal_damage?(attack.damage, attack.damage_type, attack.entity, attack.weapon.armour_pierce) unless attack == nil
			return @damage_taken unless @damage_taken === nil
			return 0
		end

		def avoided?
			return @damage_intent.avoided?
		end

		def attack_penalty?(attack_type)
			@damage_intent.attack_penalty? attack_type
		end

		def soak?(type)
			return 9001 if invulnerable
			@damage_intent.soak? type
		end

		def resist?(type)
			return 100 if invulnerable
			@damage_intent.resist? type
		end

		def describe(scope, attack)
			# Perspective is from the attacker, SELF = attacking entity
			case scope
				when BroadcastScope::SELF
					if attack.hit? && @damage_taken != nil && @damage_taken != attack.damage
						return " #{@entity.pronoun(:they).capitalize} soaked #{@damage_intent.soaked} damage."
					else
						return ''
					end
				when BroadcastScope::TARGET
					if attack.hit? && @damage_taken != nil && @damage_taken != attack.damage
						return " You soaked #{@damage_intent.soaked} damage."
					else
						return ''
					end
				when BroadcastScope::TILE
					return ''
			end
		end

	end
end