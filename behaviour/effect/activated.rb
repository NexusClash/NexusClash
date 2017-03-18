module Effect
	class Activated

		attr_reader :name
		attr_accessor :parent

		def initialize(parent, costs = nil, name = nil, targets = Array.new([:self]))
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

		def add_cost(cost, amount)
			if amount.is_a? Method
				@costs[cost.to_sym] = amount
			else
				@costs[cost.to_sym] += amount
			end
		end

		def can_target?(tar)
			if tar == :self
				@targets.include? tar
			else
				@targets.include? tar.class
			end
		end

		def activate_self_intent(intent)
			intent.name = name
			@costs.each do |cost, delta|
				intent.add_cost cost, delta
			end
		end

		def describe
			"#{@parent.name.to_s} has an activated ability called #{@name} that can target #{@targets.join ' & '}, costing #{@costs[:ap].to_s} AP + #{@costs[:mp].to_s} MP."
		end

		def save_state
			if @name === @parent.name
				[self.class.name, @costs]
			else
				[self.class.name, @costs, @name]
			end

		end

	end
end
