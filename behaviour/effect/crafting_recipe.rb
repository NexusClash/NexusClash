module Effect
	class CraftingRecipe

		attr_reader :name
		attr_reader :costs
		attr_reader :catalysts
		attr_reader :reagents
		attr_reader :outputs
		attr_reader :message

		def initialize(parent, costs = nil, catalysts = nil, reagents = nil, outputs = nil, message = nil, name = nil)
			@parent = parent
			@costs = Hash.new{|hash, key| 0}
			unless costs === nil
				costs.each do |cost, delta|
					@costs[cost.to_sym] = delta.to_i
				end
			end
			@catalysts = Hash.new
			unless catalysts === nil
				catalysts.each do |catalyst, quantity|
					@catalysts[catalyst.to_sym] = quantity.to_i
				end
			end
			@reagents = Hash.new
			unless reagents === nil
				reagents.each do |reagent, quantity|
					@reagents[reagent.to_sym] = quantity.to_i
				end
			end
			@outputs = Hash.new
			unless outputs === nil
				outputs.each do |output, quantity|
					@outputs[Entity::ItemType.find(output.to_i)] = quantity.to_i
				end
			end
			@message = message
			@name = name
			@name = @parent.name if @name === nil
		end

		def craft_intent(intent)
			intent.name = name
			@costs.each do |cost, delta|
				intent.add_cost cost, delta
			end
		end

		def describe

			stuff = ''
			@costs.each do |cost, delta|
				stuff = stuff + "#{delta.to_s} #{cost.to_s},"
			end
			@reagents.each do |agent, quantity|
				stuff = stuff + " #{quantity.to_s} #{agent.to_s}#{ quantity != 1 ? 's' : '' },"
			end
			if @catalysts.count > 0
				stuff = stuff + ' and requiring'
				@catalysts.each do |cata, quantity|
					stuff = stuff + " #{quantity.to_s} #{cata.to_s}#{ quantity != 1 ? 's' : '' },"
				end
			end
			if @outputs.count > 1
				stuff = stuff + ' and producing'
			else
				stuff = stuff + ' it produces '
			end

			@outputs.each do |item, quantity|
				stuff = stuff + " #{quantity.to_s} #{item.to_s}#{ quantity != 1 ? 's' : '' },"
			end
			return "#{@name.to_s} is a crafting recipe, costing#{stuff.chomp(',')}."
		end

		def save_state

			serialised_outputs = Hash.new

			@outputs.each do |item, quantity|
				serialised_outputs[item.id] = quantity
			end

			if @name === @parent.name
				['CraftingRecipe', @costs, @catalysts, @reagents, outputs, @message]
			else
				['CraftingRecipe', @costs, @catalysts, @reagents, outputs, @message, @name]
			end

		end

	end
end