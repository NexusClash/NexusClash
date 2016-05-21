module Behaviour
	module Aggressor
		def weaponry(target = nil)
			weaps = {}
			alters = []
			weapons = []


			self.each_applicable_effect do |effect|
				weapons << effect if effect.respond_to?(:weapon_intent)
				alters << effect if effect.respond_to?(:alter_attack_intent)
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
			weapons = self.weaponry(target)
			unless weapons.has_key? weapon_id
				Entity::Message.new({characters: [self.id], message: 'Unable to find that weapon!', type: MessageType::FAILED})
				return
			end
			if self.location != target.location
				Entity::Message.new({characters: [self.id], message: 'Your target is no longer in this location!', type: MessageType::FAILED})
				return
			end
			if self.respond_to?(:weight) && self.respond_to?(:weight_max) &&  self.weight > self.weight_max
				Entity::Message.send_transient([self.id],'You are carrying too much weight to do this!', MessageType::FAILED)
				return
			end

			attack = weapons[weapon_id]

			dmg = Intent::Damage.new(target)

			# Because Blood Claws needs to be special
			dmg.post_soak_multiplier = attack.weapon.post_soak_damage_multiplier if attack.weapon.respond_to? :post_soak_damage_multiplier

			combat = Intent::Combat.new(attack, Intent::Defend.new(target, dmg))
			combat.realise
			attack.entity.broadcast_self BroadcastScope::SELF
		end
	end
end