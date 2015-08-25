module Intent
	class Defend < Action
		def initialize(entity)
			super entity
		end

		attr_reader :damage_taken

		def take_hit(attack)
			@entity.hp = @entity.hp - attack.damage
			@damage_taken = attack.damage
			xp_gain =  @damage_taken
			xp_gain += @entity.level if @entity.dead?
			attack.grant_attacker_xp xp_gain
		end
	end
end