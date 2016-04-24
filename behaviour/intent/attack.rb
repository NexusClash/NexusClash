module Intent
	class Attack < Action

		attr_reader :weapon
		attr_accessor :message

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
			@attack_roll = rand(1..101)
			@xp_granted = 0
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

				debug weap.describe
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

		def describe(scope, defend)
			kill_msg = ''
			xp_message = ''
			xp_message = " You gain #{@xp_granted.to_s} XP." if @xp_granted > 0
			defend_msg = defend.describe(scope, self)
			case scope
				when BroadcastScope::SELF
					kill_msg = "This was enough to kill #{@target.pronoun(:him)}!" if @target.dead?
					if hit?
						return "You attack #{@target.name_link} with your #{@weapon.name} and hit, dealing #{defend.damage_taken.to_s} #{@damage_type.to_s} damage.#{defend_msg}#{xp_message}#{kill_msg}"
					else
						return "You attack #{@target.name_link} with your #{@weapon.name} and miss.#{defend_msg}"
					end
				when BroadcastScope::TARGET
					kill_msg = ' This was enough to kill you' if @target.dead?
					if hit?
						return "#{@entity.name_link} attacked you with #{@entity.pronoun(:their)} #{@weapon.name} and hit, dealing #{defend.damage_taken.to_s} #{@damage_type.to_s} damage.#{defend_msg}#{kill_msg}"
					else
						return "#{@entity.name_link} attacked you with #{@entity.pronoun(:their)} #{@weapon.name} and missed.#{defend_msg}"
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

		def to_hash
			{name: @weapon.name, hit_chance: @hit_chance, damage: @damage, damage_type: @damage_type}
		end

	end
end