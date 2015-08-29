module Entity
	class Item
		include IndefiniteArticle
		include Behaviour::Usable
		def despawn
			self.carrier.remove_child self
			self.carrier.remove_weight(self.weight) if self.carrier.respond_to? :remove_weight
			self.carrier.shard.pending_deletion << self
			self.carrier.broadcast BroadcastScope::SELF, {packets:[{type: 'inventory', weight: self.carrier.weight, list: 'remove', items: [self.object_id]}]}.to_json
		end
	end
end