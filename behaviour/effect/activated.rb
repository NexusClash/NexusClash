module Effect
	class Activated

		attr_reader :name

		def initialize(parent, costs = nil, name = nil)
			@parent = parent
			@costs = Hash.new{|hash, key| 0}
			unless costs === nil
				costs.each do |cost, delta|
					@costs[cost.to_sym] = delta
				end
			end
			@name = name
			@name = @parent.name if @name === nil
		end

		def activate_self_intent(intent)
			intent.name = name
			@costs.each do |cost, delta|
				intent.add_cost cost, delta
			end
		end

		def describe
			"#{@parent.name.to_s} has an activated ability called #{@name}, costing #{@costs[:ap].to_s} AP + #{@costs[:mp].to_s} MP."
		end

		def save_state
			if @name === @parent.name
				['Activated', @costs]
			else
				['Activated', @costs, @name]
			end

		end

	end
end