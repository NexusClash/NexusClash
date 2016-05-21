module Effect
	class RendFlesh


		def initialize(parent)
			@parent = parent
		end

		def intent_combat_hook(intent, step, pov)
			if step == :attack_hit && pov == :attacker

				rend_dmg = 1
				percent = intent.attack.target.hp * 100 / intent.attack.target.hp_max
				rend_dmg += 1 if percent < 66
				rend_dmg += 1 if percent < 33

				intent.attack.damage += rend_dmg

				intent.debug "Rend Flesh - #{percent} = #{rend_dmg} extra damage."
			end
		end

		def describe
			'Rend Flesh does 1-3 extra damage based on the target\'s missing HP %'
		end

		def save_state
			['RendFlesh']
		end
	end
end