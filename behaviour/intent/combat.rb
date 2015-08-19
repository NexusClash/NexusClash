module Intent
	class Combat

		def initialize(attack, defend)
			@attack = attack
			@defend = defend
		end

		def apply_costs
			@attack.apply_costs
		end

		def resolve
			if @attack.hit?
				@defend.take_hit @attack
			end
			message_death = nil
			attack_text = @attack.describe(BroadcastScope::SELF)
			if @attack.target.dead?

				notify = Array.new

				@attack.entity.location.characters.each do |char|
					notify << char.id unless char == @attack.entity || char == @attack.target
				end

				message_death = Entity::Message.new({characters: notify, type: :combat_attack, message: @attack.describe(BroadcastScope::TILE)}) unless notify.count == 0

			end

			message_atk = Entity::Message.new({characters: [@attack.entity.id], type: :combat_attack, message: attack_text})
			message_def = Entity::Message.new({characters: [@attack.target.id], type: :combat_defend, message: @attack.describe(BroadcastScope::TARGET)})
			@attack.entity.broadcast_self BroadcastScope::TILE
			@attack.target.broadcast_self BroadcastScope::TILE
			message_atk.save
			message_def.save
			message_death.save unless message_death === nil
		end

	end
end