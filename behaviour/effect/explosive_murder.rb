module Effect
	class ExplosiveMurder

		attr_reader :death_odds
		attr_reader :accuracy
		attr_reader :total_dmg_level_mult
		attr_reader :parent

		def initialize(parent, death_odds, accuracy, total_dmg_level_mult)
			@parent = parent
			@death_odds = death_odds
			@accuracy = accuracy
			@total_dmg_level_mult = total_dmg_level_mult
			@killer = nil
			@character = nil
		end


		def character
			if @character == nil
				@character = parent
				@character = parent.stateful if @character.is_a? Entity::Status
				@character = parent.carrier if @character.is_a? Entity::Item
			end
			@character
		end

		# EM Weapon Stats

		def name
			'Explosive Murder'
		end

		def costs
			{}
		end

		def family
			:explosive_murder
		end

		def hit_chance
			@accuracy
		end

		def damage_type
			dmg_type = :unholy
			dmg_type = :fire if rand(0..100) < 50
			dmg_type
		end

		def damage
			character.level
		end

		def armour_pierce
			0
		end

		# End EM Weapon Stats


		def tick_death(*source)
			if source.count == 0
				source = @killer
			else
				source = source[0]
			end
			explosive_murder(source) if explosive_murder?
			BroadcastScope::NONE
		end

		def tick_damage_taken(*source)
			puts source.inspect
			if source.count >= 4 && character.hp > 0 && source[1] >= character.hp # Impending killing blow
				@killer = source[3]
			else
				@killer = nil
			end
			BroadcastScope::NONE
		end

		def intent_combat_hook(intent, step, pov)
			if step == :attack_hit && pov == :attacker
				if intent.attack.weapon == self
					# Remove any buffs to the attack when EMing
					intent.attack.costs = costs
					intent.attack.family = family
					intent.attack.hit_chance = hit_chance
					intent.attack.damage_type = damage_type
					intent.attack.damage = rand(1..damage)
					intent.attack.damage = @damage_remaining if intent.attack.damage > @damage_remaining
				end
			end
			if step == :took_damage && pov == :attacker
				if intent.attack.weapon == self
					# Reduce max damage remaining
					@damage_remaining -= intent.defend.damage_taken
					@damage_remaining = 0 if @damage_remaining < 0
				end
			end
			if step == :attack_hit && pov == :defender
				if intent.defend.damage_taken(intent.attack) > intent.defend.entity.hp
					# Taking lethal damage, time to explode!
					explosive_murder(intent.attack.entity) if explosive_murder?
				end
			end
		end

		def explosive_murder?
			rand(0..100) < death_odds
		end

		def explosive_murder(cause = nil, voluntary = false)
			cause = nil unless cause != nil && cause.is_a?(Entity::Character)

			character.visibility = Visibility::SUPERINVISIBLE

			@damage_remaining = damage_max

			aoe_targets = 0
			aoe_death_count = 0
			aoe_deaths = ''

			victims = collate_targets
			witnesses = []

			character.location.characters.each do |char|
				witnesses << char.id unless char == character
			end

			victims.each do |victim|
				# Attack victim with EM
				attack = Intent::Attack.new(character, victim)
				attack.weapon = self
				combat = Intent::Combat.new(attack, Intent::Defend.new(victim))
				combat.realise

				aoe_targets += 1 if attack.hit?
				if victim.hp <= 0
					aoe_deaths << " #{victim.name_link},"
					aoe_death_count += 1
				end

				break if @damage_remaining <= 0
			end

			msg_aoe_summary_self = Entity::Message.new({characters: [character.id], type: MessageType::COMBAT_ATTACK, message: "You take a moment to concentrate your inner hatred; suddenly, with great violence, your mortal shell explodes, spewing hatred and hellfire everywhere. #{aoe_targets} characters were affected and #{aoe_death_count} died: #{aoe_deaths}."})
			msg_aoe_summary_hit = Entity::Message.new({characters: witnesses, type: MessageType::COMBAT_DEFEND, message: "#{character.name_link} has exploded in a violent flash of hatred and hellfire, spraying heat and gore everywhere. #{aoe_targets} characters were affected and #{aoe_death_count} died: #{aoe_deaths}."})
			msg_aoe_summary_self.save
			msg_aoe_summary_hit.save

			character.kill! false

			character.visibility = Visibility::VISIBLE
		end

		def damage_per_target
			character.level
		end

		def damage_max
			character.level * total_dmg_level_mult
		end

		def collate_targets
			targets = []
			character.location.characters.each do |victim|
				next if victim == character || victim.hp <= 0 || !victim.visible_to?(character) # TODO: || victim.faction == @character.faction
				targets << victim
			end
			targets.shuffle!
		end

		def describe
			"Explosive Murder: Things go BOOM when you die. #{death_odds}% chance to trigger on death, #{accuracy}% accuracy."
		end

		def save_state
			['ExplosiveMurder', death_odds, accuracy, total_dmg_level_mult]
		end
	end
end