module Behaviour
	module Crafter
		def recipes()

			recipes = []
			intents = {}

			# Gather recipes
			self.each_applicable_effect do |effect|
				recipes << effect if effect.is_a?(Effect::CraftingRecipe)
			end

			# Generate intents
			recipes.each do |recipe|
				intent = Intent::Craft.new self, recipe
				intents[recipe.object_id] = intent
			end

			return intents
		end

		def craft(recipe_id)
			recipes = self.recipes
			unless recipes.has_key? recipe_id
				Entity::Message.new({characters: [self.id], message: 'Unable to find that recipe!', type: MessageType::FAILED})
				return
			end
			if self.respond_to?(:weight) && self.respond_to?(:weight_max) &&  self.weight > self.weight_max
				Entity::Message.send_transient([self.id],'You are carrying too much weight to do this!', MessageType::FAILED)
				return
			end

			recipe = recipes[recipe_id]

			recipe.realise
		end
	end
end