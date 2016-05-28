module Intent
	class Craft < Action
		attr_accessor :entity
		attr_reader :recipe

		def initialize(entity, recipe)
			super entity
			@recipe = recipe
			# Add conventional costs
			recipe.costs.each do |type, delta|
				@costs[type.to_sym] = delta.to_i
			end
			debug recipe
		end

		def remaining
			compile_costs if @remaining === nil
			@remaining
		end

		def remaining_catalysts
			compile_costs if @remaining_catalysts === nil
			@remaining_catalysts
		end

		def possible?
			possible = super
			compile_costs if possible && (@remaining === nil || @remaining_catalysts === nil)
			return possible && @remaining.size == 0 && @remaining_catalysts.size == 0
		end

		def apply_costs
			super
			@used_items.each do |item|
				debug "Used up #{item.name}"
				item.despawn
			end
		end

		def take_action
			item_packets = Array.new
			@recipe.outputs.each do |output, quantity|
				(1..quantity).each do |_|
					item = Entity::Item.source_from(output.id)
					item.carrier = entity
					item_packets << item.to_h
				end
			end
			@item_packets = item_packets
		end

		def broadcast_results
			message_ent = Entity::Message.new({characters: [entity.id], message: @recipe.message, type: MessageType::CRAFT_SUCCESS})
			entity.broadcast BroadcastScope::SELF, {packets:[{type: 'inventory', weight: entity.weight, weight_max: entity.weight_max, list: 'add', items: @item_packets}]}.to_json
			entity.broadcast_self BroadcastScope::SELF
			message_ent.save
		end


		def to_h
			output = {}
			@recipe.outputs.each do |item, quantity|
				output[item.name] = quantity
			end

			{id: @recipe.object_id, name: recipe.name, possible: possible?, costs: @recipe.costs, reagents_missing: remaining, catalysts_missing: remaining_catalysts, catalysts: @recipe.catalysts, reagents: @recipe.reagents, outputs: output}
		end

		private

		def compile_costs
			remaining = @recipe.reagents.clone
			remaining_catalysts = @recipe.catalysts.clone
			used_items = Array.new
			entity.items.each do |item|
				consumed = false
				item.statuses.each do |status|
					status.effects.each do |effect|
						if effect.respond_to?(:component)
							# Check for reagent
							if remaining.has_key?(effect.component) && remaining[effect.component] > 0
								remaining[effect.component] = remaining[effect.component] - 1
								consumed = true
								debug effect
								used_items << item
								break
							end
							# Check for catalyst
							if remaining_catalysts.has_key?(effect.component) && remaining_catalysts[effect.component] > 0
								remaining_catalysts[effect.component] = remaining_catalysts[effect.component] - 1
								debug effect
								break
							end
						end
					end
					break if consumed
				end
				unless consumed
					item.type_statuses.each do |status|
						status.effects.each do |effect|
							if effect.respond_to?(:component)
								# Check for reagent
								if remaining.has_key?(effect.component) && remaining[effect.component] > 0
									remaining[effect.component] = remaining[effect.component] - 1
									consumed = true
									debug effect
									used_items << item
									break
								end
								# Check for catalyst
								if remaining_catalysts.has_key?(effect.component) && remaining_catalysts[effect.component] > 0
									remaining_catalysts[effect.component] = remaining_catalysts[effect.component] - 1
									debug effect
									break
								end
							end
						end
						break if consumed
					end
				end
			end
			# Look for catalysts on location
			entity.location.statuses.each do |status|
				status.effects.each do |effect|
					if effect.respond_to?(:component)
						# Check for catalyst
						if remaining_catalysts.has_key?(effect.component) && remaining_catalysts[effect.component] > 0
							remaining_catalysts[effect.component] = remaining_catalysts[effect.component] - 1
							debug effect
							break
						end
					end
				end
			end
			remaining.delete_if {|_, value| value == 0}
			remaining_catalysts.delete_if {|_, value| value == 0}
			@remaining = remaining
			@remaining_catalysts = remaining_catalysts
			@used_items = used_items
		end

	end
end
