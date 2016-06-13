module Intent
	class Combat < Action


		attr_reader :attack
		attr_reader :defend
		attr_accessor :mo_delta

		def initialize(attack, defend)
			super attack.entity, {encumbrance: false, status_tick: false, unhide: false, alive: false} # checks get done in Attack intent
			@mo_delta = 0
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
			end
			@attack.possible?
		end

		def take_action
			attacker_hooks = collate_combat_hooks @attack.entity
			defender_hooks = collate_combat_hooks @attack.target
			debug "Effective hit % after close/ranged avoidance: #{@attack.hit_chance}"
			@attack.hit_chance = 0 if @defend.avoided?
			debug 'Missed due to generic avoidance!' if @defend.avoided?
			if @attack.hit?
				debug 'Attack hit!'
				attacker_hooks.each {|hook| hook.intent_combat_hook self, :attack_hit, :attacker}
				defender_hooks.each {|hook| hook.intent_combat_hook self, :attack_hit, :defender}
				@defend.take_hit(@attack)
				case @attack.target.alignment
					when :good
						@mo_delta = @defend.damage_taken * -2
						# -3 MO for goods hitting goods
						@mo_delta -= 30 if @attack.entity.alignment == :good
						# -1 MO for goods killing goods (total -4)
						@mo_delta -= 10 if @attack.entity.dead?
					when :neutral
						@mo_delta = -@defend.damage_taken
						# -2 MO for goods killing neutrals
						@mo_delta -= 20 if @attack.entity.dead? && @attack.entity.alignment == :good
					when :evil
						unless @attack.entity.alignment == :evil
							@mo_delta = @defend.damage_taken unless @attack.entity.alignment == :evil # TODO: unless @attack.target.faction.alignment == :evil || @attack.target.is_demon
							# +1 MO for non-evil killing evil
							@mo_delta += 10 if @attack.target.dead?
						end
				end
				attacker_hooks.each {|hook| hook.intent_combat_hook self, :took_damage, :attacker}
				defender_hooks.each {|hook| hook.intent_combat_hook self, :took_damage, :defender}
				@attack.entity.mo += @mo_delta
			end
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

			weapon = attack.weapon
			alters = []
			if weapon.respond_to? :weapon_intent

				entity.each_applicable_effect do |effect|
					alters << effect if effect.respond_to?(:alter_attack_intent)
				end

				intent = weapon.weapon_intent(Intent::Attack.new(entity, attack.target))
				alters.each do |alter|
					intent = alter.alter_attack_intent(intent)
				end
				weaps_hash = {}
				weaps_hash[weapon.object_id] = intent.to_hash

				entity.broadcast BroadcastScope::SELF, {packets: [{type: 'actions', mode: 'update', actions: {attacks: weaps_hash}}]}.to_json
			end
		end

		private

		def collate_combat_hooks(entity)
			hooks = []
			entity.each_applicable_effect do |effect|
				hooks << effect if effect.respond_to? :intent_combat_hook
			end
			return hooks
		end

	end
end