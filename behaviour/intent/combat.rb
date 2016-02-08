module Intent
	class Combat < Action

		def initialize(attack, defend)
			@attack = attack
			@defend = defend
			@attack.hit_chance -= defend.attack_penalty?(DefenceType::CLOSE_COMBAT_AVOIDANCE) if @attack.close_combat?
			@attack.hit_chance -= defend.attack_penalty?(DefenceType::RANGED_COMBAT_AVOIDANCE) if @attack.ranged_combat?
		end

		def apply_costs
			@attack.apply_costs
		end

		def possible?
			@attack.possible?
		end

		def take_action
			@attack.hit_chance = 0 if @defend.avoided?
			@defend.take_hit(@attack) if @attack.hit?
		end

		def broadcast_results
			#TODO: Split into Intent::Attack and Intent::Defend
			message_death = nil
			attack_text = @attack.describe(BroadcastScope::SELF, @defend)
			if @attack.target.dead?

				notify = Array.new

				@attack.entity.location.characters.each do |char|
					notify << char.id unless char == @attack.entity || char == @attack.target
				end

				message_death = Entity::Message.new({characters: notify, type: MessageType::COMBAT_ATTACK, message: @attack.describe(BroadcastScope::TILE, @defend)}) unless notify.count == 0

			end

			message_atk = Entity::Message.new({characters: [@attack.entity.id], type: MessageType::COMBAT_ATTACK, message: attack_text})
			message_def = Entity::Message.new({characters: [@attack.target.id], type: MessageType::COMBAT_DEFEND, message: @attack.describe(BroadcastScope::TARGET, @defend)})
			@attack.entity.broadcast_self BroadcastScope::TILE
			@attack.target.broadcast_self BroadcastScope::TILE
			message_atk.save
			message_def.save
			message_death.save unless message_death === nil
		end

	end
end