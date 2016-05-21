module Effect
	class ShieldOfFaith < Effect::ActOnTick

		attr_reader :damage_threshold
		attr_reader :charges

		def initialize(parent, damage_threshold, charges)
			super parent, :none
			@damage_threshold = damage_threshold
			@charges = charges
			duration = @charges
			duration = @parent.get_tag(:charges) if @parent.respond_to? :get_tag
			if duration === nil
				@parent.set_tag :charges, @charges if @parent.respond_to? :set_tag
			end
		end

		def tick_event(defender, attacker)
			duration = @parent.get_tag(:charges)
			duration = @charges if duration === nil
			duration = duration.to_i
			duration -= 1

			defender = defender.carrier if defender.is_a? Entity::Item
			defender = defender.stateful if defender.is_a? Entity::Status

			attacker = attacker.carrier if defender.is_a? Entity::Item
			attacker = attacker.stateful if attacker.is_a? Entity::Status

			msg = Entity::Message.new({characters: [attacker.id],message: "#{defender.name_link}'s #{@parent.name} triggered, negating all damage from your attack!", type: MessageType::GENERIC})
			msg.save

			msg = Entity::Message.new({characters: [defender.id],message: "Your #{@parent.name} triggered, negating all damage from #{attacker.name_link}'s attack!", type: MessageType::GENERIC})
			msg.save

			@parent.set_tag :charges, duration
			if duration < 1
				@parent.dispel

				msg = Entity::Message.new({characters: [defender.id],message: "You are no longer under the effects of #{@parent.name}.", type: MessageType::STATUS_EXPIRY})
				msg.save
			end
			return BroadcastScope::SELF
		end

		def intent_combat_hook(intent, step, pov)
			if step == :attack_hit && pov == :defender
				if intent.defend.damage_taken(intent.attack) > damage_threshold
					intent.defend.invulnerable = true
					tick_event intent.attack.entity, intent.attack.target
				end
			end
		end

		def describe
			"If you would take #{damage_threshold} or more damage, negate that damage. Works #{charges} time#{ charges == 1 ? '' : 's' }."
		end

		def save_state
			['ShieldOfFaith', damage_threshold, charges]
		end
	end
end