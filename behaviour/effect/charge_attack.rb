module Effect
	class ChargeAttack


		attr_reader :damage_type
		attr_reader :damage
		attr_reader :hit_chance
		attr_reader :parent
		attr_reader :name
		attr_reader :costs

		def initialize(parent, costs = nil, name = nil, damage = 0, damage_type = :none, hit_chance = 0)
			@parent = parent
			@damage_type = damage_type.to_sym
			@hit_chance = hit_chance.to_i
			@damage = damage.to_i
			@name = name
			@name = @parent.name if @name === nil
			@costs = Hash.new{|hash, key| 0}
			unless costs === nil
				costs.each do |cost, delta|
					@costs[cost.to_sym] = delta
				end
			end
		end

		def apply_charge_attack(intent)
			intent.damage += @damage
			intent.hit_chance += @hit_chance
			intent.damage_type = @damage_type unless @damage_type == :none || @damage_type == nil
			intent.append_message "This attack was a #{@name}!"
		end

		def describe
			msg = "#{@name} is a charge attack costing #{@costs[:ap].to_s} AP + #{@costs[:mp].to_s} MP."
			msg << " Increases damage by #{damage}." if damage != 0
			msg << " Changes damage type to #{damage_type}." unless damage_type == nil || damage_type == :none
			msg << " Increases hit chance by #{hit_chance}." if damage != 0
			return msg
		end


		def save_state
			['ChargeAttack', @costs, @name, @damage, @damage_type, @hit_chance]
		end
	end
end