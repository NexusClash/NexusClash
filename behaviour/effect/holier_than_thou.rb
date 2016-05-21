module Effect
	class HolierThanThou

		attr_reader :parent

		def initialize(parent)
			@parent = parent
		end

		def describe
			'Holier Than Thou stuff'
		end

		def intent_combat_hook(intent, step, pov)
			if step == :took_damage && pov == :attacker
				case intent.attack.target.nexus_class
					# TODO: less awful way of determining class alignment
					when 'Paladin', 'Holy Champion', 'Seraph', 'Divine Herald', 'Redeemed', 'Shepherd', 'Lightspeaker', 'Advocate', 'Archon'
						# half MO drop when attacking angels with lesser MO
						intent.mo_delta /= 2 if intent.mo_delta < 0 && intent.attack.target.mo < intent.attack.entity.mo
					else
						# no MO drop when attacking non-angels with lesser MO
						intent.mo_delta = 0 if intent.mo_delta < 0 && intent.attack.target.mo < intent.attack.entity.mo
				end
			end
		end

		def save_state
			['HolierThanThou']
		end
	end
end