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

		attr_accessor :debug_log

		def initialize(entity, target = nil)
			super entity
			@target = target
			@attack_roll = rand(1..101)
			@costs = Hash.new{|hash, key| hash[key] = 0}
			@costs[:ap] = 1
			@xp_granted = 0
			@debug_log = Array.new
		end

		def weapon=(weap)
			unless @weapon == weap
				@weapon = weap

				@family = weap.family
				@hit_chance = weap.hit_chance
				@damage_type = weap.damage_type
				@damage = weap.damage

				@debug_log << weap.describe
			end
		end

		def grant_attacker_xp(xp_amount)
			@xp_granted += xp_amount
			@entity.xp += xp_amount
		end

		def describe(scope)
			kill_msg = ''
			xp_message = ''
			xp_message = " You gain #{@xp_granted.to_s} XP." if @xp_granted > 0
			case scope
				when BroadcastScope::SELF
					kill_msg = ", killing #{@target.pronoun(:him)}" if @target.dead?
					if hit?
						return "You attack #{@target.name_link} with your #{@weapon.name} and hit, dealing #{@damage.to_s} #{@damage_type.to_s} damage#{kill_msg}!#{xp_message}"
					else
						return "You attack #{@target.name_link} with your #{@weapon.name} and miss!"
					end
				when BroadcastScope::TARGET
					kill_msg = '. This was enough to kill you' if @target.dead?
					if hit?
						return "#{@entity.name_link} attacked you with #{@entity.pronoun(:their)} #{@weapon.name} and hit, dealing #{@damage.to_s} #{@damage_type.to_s} damage#{kill_msg}!"
					else
						return "#{@entity.name_link} attacked you with #{@entity.pronoun(:their)} #{@weapon.name} and missed!"
					end
				when BroadcastScope::TILE
					kill_msg = ", killing #{@target.pronoun(:him)}" if @target.dead?
					if hit?
						return "#{@entity.name_link} attacked #{@target.name_link} with #{@entity.pronoun(:their)} #{@weapon.name} and hit#{kill_msg}!"
					else
						return "#{@entity.name_link} attacked #{@target.name_link} with #{@entity.pronoun(:their)} #{@weapon.name} and missed#{kill_msg}!"
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