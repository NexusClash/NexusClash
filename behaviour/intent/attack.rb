module Intent
	class Attack < Action

		attr_reader :weapon
		attr_reader :charge_attack
		attr_accessor :message
		attr_accessor :costs

		attr_accessor :family
		attr_accessor :hit_chance
		attr_accessor :damage_type
		attr_accessor :damage

		attr_accessor :attack_roll

		attr_accessor :target
		attr_accessor :entity

		def initialize(entity, target = nil)
			super entity
			@target = target
			@attack_roll = rand(1..100)
			debug "Attack Roll: #{@attack_roll}"
			@xp_granted = 0
			@additional_text_attacker = ''
			@additional_text_defender = ''
		end

		def weapon=(weap)
			unless @weapon == weap
				@weapon = weap

				@weapon.costs.each do |key, value|
					if value.respond_to? :call
						@costs[key] = value
					else
						@costs[key] += value
					end

				end

				@family = weap.family
				@hit_chance = weap.hit_chance
				@damage_type = weap.damage_type
				@damage = weap.damage

				debug weap
			end
		end

		def charge_attack=(charge)
			unless @charge_attack == charge
				@charge_attack = charge
				@charge_attack.costs.each do |key, value|
					if value.respond_to? :call
						@costs[key] = value
					else
						@costs[key] += value
					end
				end
				@charge_attack.apply_charge_attack self
				debug charge
			end
		end

		def grant_attacker_xp(xp_amount)
			@xp_granted += xp_amount
			@entity.xp += xp_amount
		end

		def close_combat?
			return Set[:all, :heavy, :melee, :unarmed].include? @family
		end

		def ranged_combat?
			return Set[:all, :archery, :firearm, :magical, :thrown ].include? @family
		end

		def append_message(text, scope = :all)
			unless scope === :defender
				@additional_text_attacker << ' '
				@additional_text_attacker << text
			end
			unless scope === :attacker
				@additional_text_defender << ' '
				@additional_text_defender << text
			end
		end

		def describe(scope, defend)
			kill_msg = ''
			xp_message = ''
			xp_message = " You gain #{@xp_granted.to_s} XP." if @xp_granted > 0
			defend_msg = defend.describe(scope, self)
			case scope
				when BroadcastScope::SELF
					debug_broadcast(@entity.id)
					kill_msg = " This was enough to kill #{@target.pronoun(:him)}!" if @target.dead?
					if hit?
						return "You attack #{@target.name_link} with your #{@weapon.name} and hit, dealing #{defend.damage_taken.to_s} #{@damage_type.to_s} damage.#{defend_msg}#{@additional_text_attacker}#{xp_message}#{kill_msg}"
					else
						return "You attack #{@target.name_link} with your #{@weapon.name} and miss.#{defend_msg}#{@additional_text_attacker}"
					end
				when BroadcastScope::TARGET
					kill_msg = ' This was enough to kill you' if @target.dead?
					if hit?
						return "#{@entity.name_link} attacked you with #{@entity.pronoun(:their)} #{@weapon.name} and hit, dealing #{defend.damage_taken.to_s} #{@damage_type.to_s} damage.#{defend_msg}#{@additional_text_defender}#{kill_msg}"
					else
						return "#{@entity.name_link} attacked you with #{@entity.pronoun(:their)} #{@weapon.name} and missed.#{defend_msg}#{@additional_text_defender}"
					end
				when BroadcastScope::TILE
					kill_msg = ", killing #{@target.pronoun(:him)}" if @target.dead?
					if hit?
						return "#{@entity.name_link} attacked #{@target.name_link} with #{@entity.pronoun(:their)} #{@weapon.name} and hit#{kill_msg == '' ? '.' : ''}#{kill_msg}"
					else
						return "#{@entity.name_link} attacked #{@target.name_link} with #{@entity.pronoun(:their)} #{@weapon.name} and missed#{kill_msg == '' ? '.' : ''}#{kill_msg}"
					end
			end
		end

		def hit?
			@attack_roll <= @hit_chance
		end

		def damage_description
			@damage_description || @damage.to_s
		end

		def damage_description=(value)
			@damage_description = value
		end

		def to_hash
			{name: @weapon.name, hit_chance: hit_chance, damage: damage_description, damage_type: @damage_type}
		end

	end
end
