module Intent
	class Combat < Action

		def initialize(attack, defend)
			super attack.entity, {encumbrance: false, status_tick: false} # checks get done in Attack intent
			@attack = attack
			@defend = defend
			@attack.hit_chance -= defend.attack_penalty?(DefenceType::CLOSE_COMBAT_AVOIDANCE) if @attack.close_combat?
			@attack.hit_chance -= defend.attack_penalty?(DefenceType::RANGED_COMBAT_AVOIDANCE) if @attack.ranged_combat?
		end

		def apply_costs
			@attack.apply_costs
			Entity::Status.tick(@attack.target, StatusTick::STATUS)
		end

		def possible?
			unless @attack.possible?
				debug 'Not possible to attack'
				debug_broadcast @attack.entity.id
			end
			@attack.possible?
		end

		def take_action
			debug "Effective hit % after close/ranged avoidance: #{@attack.hit_chance}"
			@attack.hit_chance = 0 if @defend.avoided?
			debug 'Missed due to generic avoidance!' if @defend.avoided?
			if @attack.hit?
				debug 'Attack hit!'
				@defend.take_hit(@attack)
				case @attack.target.alignment
					when :good
						@attack.entity.mo -= @defend.damage_taken * 2
					when :neutral
						@attack.entity.mo -= @defend.damage_taken
					when :evil
						@attack.entity.mo += @defend.damage_taken # TODO: unless @attack.target.faction.alignment == :evil || @attack.target.is_demon
				end
			end
		end

		def broadcast_results
			#TODO: Split into Intent::Attack and Intent::Defend
			message_death = nil
			attack_text = @attack.describe(BroadcastScope::SELF, @defend)
			debug_broadcast @attack.entity.id
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