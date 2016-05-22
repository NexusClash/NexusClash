module Effect
	class Smite < Effect::ChargeAttack


		attr_reader :evil_damage
		attr_reader :demon_damage

		def initialize(parent, costs = nil, name = nil, damage = 0, damage_type = :none, hit_chance = 0, evil_damage = 0, demon_damage = 0)
			super parent, costs, name, damage, damage_type, hit_chance
			@evil_damage = evil_damage
			@demon_damage = demon_damage
		end

		def apply_charge_attack(intent)
			super intent
			intent.damage += evil_damage if intent.target.alignment == :evil
			intent.damage += demon_damage if ['Pariah', 'Defiler', 'Fallen', 'Infernal Behemoth', 'Void Walker', 'Doom Howler', 'Corruptor', 'Dark Oppressor', 'Wyrm Master'].include? intent.target.nexus_class
		end

		def describe
			msg = super
			msg << " Increases damage by #{evil_damage} vs evil targets." if evil_damage != 0
			msg << " Increases damage by #{demon_damage} vs demons." if demon_damage != 0
			msg
		end


		def save_state
			state = super
			state << evil_damage
			state << demon_damage
			state
		end
	end
end