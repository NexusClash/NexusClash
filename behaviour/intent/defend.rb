module Intent
	class Defend < Action
		def initialize(entity, damage_intent = nil)
			super entity, {encumbrance: false, status_tick: false, unhide: false}
			if damage_intent === nil
				@damage_intent = Intent::Damage.new entity
			else
				@damage_intent = damage_intent
			end
		end

		def take_hit(attack)
			@damage_taken = xp_gain =  @damage_intent.deal_damage(attack.damage, attack.damage_type)
			xp_gain += @entity.level if @entity.dead?
			attack.grant_attacker_xp xp_gain
		end

		def damage_taken
			@damage_taken
		end

		def avoided?
			return @damage_intent.avoided?
		end

		def attack_penalty?(attack_type)
			@damage_intent.attack_penalty? attack_type
		end

		def soak?(type)
			@damage_intent.soak? type
		end

		def resist?(type)
			@damage_intent.resist? type
		end

		def describe(scope, attack)
			# Perspective is from the attacker, SELF = attacking entity
			case scope
				when BroadcastScope::SELF
					if attack.hit? && @damage_taken != nil && @damage_taken != attack.damage
						return " #{@entity.pronoun(:they)} soaked #{attack.damage - @damage_taken} damage."
					else
						return ''
					end
				when BroadcastScope::TARGET
					if attack.hit? && @damage_taken != nil && @damage_taken != attack.damage
						return " You soaked #{attack.damage - @damage_taken} damage."
					else
						return ''
					end
				when BroadcastScope::TILE
					return ''
			end
		end

	end
end