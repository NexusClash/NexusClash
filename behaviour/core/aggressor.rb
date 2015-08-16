module Behaviour
	module Aggressor
		def weaponry?(target = nil)
			weaps = {}
			alters = []
			weapons = []


			# Gather weapon and weapon altering effects
			self.statuses.each do |status|
				status.effects.each do |effect|
					weapons << effect if effect.respond_to?(:weapon_intent)
					alters << effect if effect.respond_to?(:alter_attack_intent)
				end
			end
			self.items.each do |item|
				item.statuses.each do |status|
					status.effects.each do |effect|
						weapons << effect if effect.respond_to?(:weapon_intent)
						alters << effect if effect.respond_to?(:alter_attack_intent)
					end
				end
				item.type_statuses.each do |status|
					status.effects.each do |effect|
						weapons << effect if effect.respond_to?(:weapon_intent)
						alters << effect if effect.respond_to?(:alter_attack_intent)
					end
				end
			end

			# Generate weapons
			weapons.each do |weapon|
				intent = weapon.weapon_intent(Intent::Attack.new(self, target))
				alters.each do |alter|
					intent = alter.alter_attack_intent(intent)
				end
				weaps[weapon.object_id] = intent
			end

			return weaps
		end

		def attack(target, weapon_id)

			weapons = self.weaponry?(target)

			unless weapons.has_key? weapon_id
				Entity::Message.new({characters: [self.id], message: 'Unable to find that weapon!'})
				return
			end
			if self.location != target.location
				Entity::Message.new({characters: [self.id], message: 'Your target is no longer in this location!'})
				return
			end

			attack = weapons[weapon_id]

			combat = Intent::Combat.new(attack, Intent::Defend.new(target))
			combat.apply_costs
			combat.resolve
			attack.entity.broadcast_self BroadcastScope::SELF
		end
	end
end