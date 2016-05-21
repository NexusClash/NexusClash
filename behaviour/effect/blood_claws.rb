module Effect
	class BloodClaws

		attr_reader :family
		attr_reader :hit_chance
		attr_reader :damage_type
		attr_reader :damage
		attr_reader :name
		attr_reader :parent
		attr_reader :costs
		attr_reader :armour_pierce

		def initialize(parent, damage = 6)
			@costs = {ap: 1}
			@parent = parent
			@family = :special
			@hit_chance = 100
			@damage_type = :special
			@damage = damage
			@armour_pierce = 0
			@name = parent.name
		end

		def weapon_intent(intent)
			intent.weapon = self
			intent.add_cost :blood_claws, self.method(:setup_claws)
			return intent
		end

		def setup_claws(action, intent)
			if action == :possible? # need to apply before charge attacks!
				case intent.entity.nexus_class
					when 'Pariah'
						damage_types = [[:slashing, 60], [:piercing, 25], [:impact, 10], [:unholy, 5]]
					when 'Infernal Behemoth'
						damage_types = [[:slashing, 35], [:fire, 35], [:piercing, 20], [:unholy, 10]]
					when 'Doom Howler'
						damage_types = [[:slashing, 25], [:death, 25], [:cold, 25], [:piercing, 15], [:unholy, 10]]
					when 'Void Walker'
						damage_types = [[:slashing, 25], [:death, 25], [:piercing, 25], [:unholy, 25]]
					when 'Redeemed'
						damage_types = [[:slashing, 60], [:piercing, 25], [:holy, 15]]
					else
						damage_types = [[:slashing, 60], [:piercing, 25], [:impact, 10], [:unholy, 5]] # some other class D:
				end
				rnd_max = damage_types.inject(0) { |sum, itm| sum + itm[1] }
				roll = rand(1..rnd_max)
				damage_types.each do |possibility|
					roll -= possibility[1]
					unless roll > 0
						intent.damage_type = possibility[0]
						break
					end
				end
			end
			true
		end

		def post_soak_damage_multiplier
			0.75
		end

		def describe
			"#{@name.to_s} is a special (Blood Claws) weapon that has a variable damage type."
		end

		def save_state
			['BloodClaws', @damage]
		end

	end
end