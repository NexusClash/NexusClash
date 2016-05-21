module Effect
	class DamageReducesDuration < Effect::ActOnDamage

		attr_reader :damage_multiplier
		attr_reader :constant_reduction
		attr_reader :damage_divider

		def initialize(parent, constant_reduction = 0, damage_multiplier = 1, damage_divider = 1)
			super parent
			@constant_reduction = constant_reduction
			@damage_multiplier = damage_multiplier
			@damage_divider = damage_divider
		end

		def tick_event(*target)

			entity = target[0]
			damage = target[1]
			#type = target[2]
			#source = target[3]

			duration = @parent.get_tag(:duration)
			duration = 0 if duration === nil
			duration = duration.to_i
			duration -= @constant_reduction + (damage * @damage_multiplier / @damage_divider).round
			@parent.set_tag :duration, duration
			if duration < 1
				@parent.dispel

				entity = entity.stateful if entity.is_a? Entity::Status
				entity = entity.carrier if entity.is_a? Entity::Item

				msg = Entity::Message.new({characters: [entity.id],message: "You are no longer under the effects of #{@parent.name}.", type: MessageType::STATUS_EXPIRY})
				msg.save
			end
			return BroadcastScope::SELF
		end

		def describe
			super + "duration is reduced by #{@constant_reduction} + (Damage X #{@damage_multiplier} / #{@damage_divider})"
		end

		def save_state
			['DamageReducesDuration', @constant_reduction, @damage_multiplier, @damage_divider]
		end
	end
end