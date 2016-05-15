module Effect
	class CombinationAttack

		attr_reader :parent, :attack_interval, :base_bonus, :level_mult, :level_div

		def initialize(parent, attack_interval = 3, base_bonus = 6, level_mult = 0, level_div = 1)
			@parent = parent
			@attack_interval = attack_interval
			@base_bonus = base_bonus
			@level_mult = level_mult
			@level_div = level_div
		end

		def name
			@parent.name
		end

		def alter_attack_intent(intent)
			intent.debug self
			if intent.hit?
				interval = attack_interval_counter
				if interval == 0
					intent.append_message(' This was a combination attack!')
					damage = base_bonus + (intent.entity.level * level_mult / level_div).floor
					intent.damage += damage
					intent.debug "Combination Attack has increased damage by #{damage}"
					interval = attack_interval
				else
					interval -= 1
					intent.debug "Combination Attack not firing on this attack - #{interval} attacks until next trigger"
					self.attack_interval_counter = interval
				end
			else
				intent.debug 'Combination Attack only cares about attacks that hit'
			end
			return intent
		end

		def describe
			text = "Every #{attack_interval} attacks, apply #{base_bonus} + (level"
			text << " * #{level_mult}" unless level_mult == 1
			text << " / #{level_div}" unless level_div == 1
			text << ') bonus damage'
			return text
		end

		def save_state
			['CombinationAttack', attack_interval, base_bonus, level_mult, level_div]
		end

		private

		def attack_interval_counter
			interval_remaining = @parent.get_tag(:combination_interval) if @parent.respond_to? :get_tag
			if interval_remaining === nil
				@parent.set_tag :combination_interval, attack_interval if @parent.respond_to? :set_tag
			end
			return interval_remaining
		end

		def attack_interval_counter=(val)
			@parent.set_tag :combination_interval, val if @parent.respond_to? :set_tag
		end
	end
end