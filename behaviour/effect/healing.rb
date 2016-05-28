module Effect
	class Healing < Effect::ActOnTick

		def initialize(parent, interval, amount)
			super parent, interval
			@amount = amount.to_i
		end

		def tick_event(*entities)
			source = nil
			target = nil

			if entities.count > 1
				source = entities[0]
				target = entities[1]
			else
				source = entities[0]
				target = source
			end
			source = source.carrier if source.is_a? Entity::Item
			target = target.carrier if target.is_a? Entity::Item

			amount_modification = 0

			source.each_applicable_effect do |effect|
				amount_modification += effect.increase_healing(source, target, @amount)  if effect.respond_to? :increase_healing
			end
			source.location.statuses.each do |status|
				status.effects.each do |effect|
					amount_modification += effect.increase_healing(source, target, @amount)  if effect.respond_to? :increase_healing
				end
			end

			initialval = target.hp
			val = initialval
			delta = @amount + amount_modification
			max = target.hp_max
			if val + @amount > max then
				if val > max
					delta = 0
				else
					delta = max - val
					val = max
				end
			else
				val += @amount
			end
			target.hp = val

			@parent.temp_effect_vars[:hp] = delta

			return BroadcastScope::NONE if val == initialval

			if target != source
				source.xp += delta
				source.mo += delta
				@parent.temp_effect_vars[:xp] = delta.to_f / 10
				@parent.temp_effect_vars[:mo] = delta
				source.broadcast_self BroadcastScope::SELF
			else
				@parent.temp_effect_vars[:xp] = 0
				@parent.temp_effect_vars[:mo] = 0
			end
			return BroadcastScope::TILE
		end

		def describe
			super + "heal for #{@amount.to_s} HP (affected by effects that increase healing)."
		end

		def save_state
			super.push @amount
		end
	end
end