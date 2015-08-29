##
# This class represents an action being taken by an entity (usually a character or pet)

module Intent
	class Action

		def initialize(entity)
			@entity = entity
			@costs = Hash.new{|hash, key| 0}
		end

		##
		# Add a cost to the intended action
		def add_cost(cost, amount)
			if amount.is_a? Method
				@costs[cost.to_sym] = amount
			else
				@costs[cost.to_sym] += amount
			end

		end

		##
		# Apply the costs of this intended action
		def apply_costs
			@costs.each do |cost, delta|
				if delta.is_a? Method
					delta.call :apply_costs, self
				else
					if delta != 0 && @entity.respond_to?(cost)
						cost_set = (cost.to_s + '=').to_sym
						value = @entity.send cost
						value -= delta
						@entity.send cost_set, value
					end
				end

			end
		end

		##
		# Determine if the costs of intended action can be met
		# Note that costs can be negative to represent gains (negative morality costs will function correctly)
		def possible?
			@costs.each do |cost, delta|
				if delta.is_a? Method # This cost requires a callback to evaluate
					return false unless delta.call :possible?, self
				else # We're dealing with a regular numeric cost
					# Skip bounds checking for costs with no associated change
					if delta != 0 && @entity.respond_to?(cost)
						value = @entity.send cost
						minimum = (cost.to_s + '_min').to_sym
						maximum = (cost.to_s + '_max').to_sym
						if delta > 0 && @entity.respond_to?(minimum)
							return false if value - delta < @entity.send(minimum)
						end
						if delta < 0 && @entity.respond_to?(maximum)

							return false if value - delta > @entity.send(maximum)
						end

						return false if value < delta
					end
				end
			end
			return true
		end

		def realise
			if possible?
				apply_costs
				take_action if respond_to? :take_action
				broadcast_results if respond_to? :broadcast_results
			end
		end

		alias :realize :realise
	end
end