module Effect
	class ActivatedTarget < Activated

		attr_reader :name

		def initialize(parent, costs = nil, name = nil, targets = [:self, Entity::Character])
			@parent = parent
			@targets = targets
			@costs = Hash.new{|hash, key| 0}
			unless costs === nil
				costs.each do |cost, delta|
					@costs[cost.to_sym] = delta
				end
			end
			@name = name
			@name = @parent.name if @name === nil
		end

		def activate_target_intent(intent)
			intent.name = name
			@costs.each do |cost, delta|
				intent.add_cost cost, delta
			end
		end

		def save_state
			if @name === @parent.name
				['ActivatedTarget', @costs]
			else
				['ActivatedTarget', @costs, @name]
			end

		end

	end
end