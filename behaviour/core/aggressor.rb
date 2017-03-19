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

		def charge_attacks(select = nil)
			if select === nil
				charge_attacks = []
				self.each_applicable_effect do |effect|
					charge_attacks << effect if effect.respond_to?(:apply_charge_attack)
				end
				return charge_attacks
			else
				self.each_applicable_effect do |effect|
					if effect.respond_to?(:apply_charge_attack) && effect.object_id == select
						return effect
					end
				end
				return nil
			end
		end

		def attack(target, weapon_id, charge_attack = nil)
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

			charge_attack = charge_attacks(charge_attack) unless charge_attack === nil
			attack.charge_attack = charge_attack unless charge_attack === nil

			dmg = Intent::Damage.new(target)

			# Because Blood Claws needs to be special
			dmg.post_soak_multiplier = attack.weapon.post_soak_damage_multiplier if attack.weapon.respond_to? :post_soak_damage_multiplier

			combat = Intent::Combat.new(attack, Intent::Defend.new(target, dmg))
			if combat.realise
				attack.entity.broadcast_self BroadcastScope::SELF
			else # Try again without charge attack if not able to do charge attack
				attack target, weapon_id unless charge_attack === nil
			end
		end
	end
end
