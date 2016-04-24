module Entity
	class Item
		include IndefiniteArticle
		include Behaviour::Usable
		def despawn
			if DB_PERSIST_MODE === DB_PERSIST_DELAYED
				self.carrier.remove_child self
				self.carrier.remove_weight(self.weight) if self.carrier.respond_to? :remove_weight
				self.carrier.shard.pending_deletion << self
				self.carrier.broadcast BroadcastScope::SELF, {packets:[{type: 'inventory', weight: self.carrier.weight, list: 'remove', items: [self.object_id]}]}.to_json
			else
				object_id = self.object_id
				carrier = self.carrier
				self.destroy
				carrier.remove_weight(self.weight) if carrier.respond_to? :remove_weight
				carrier.broadcast BroadcastScope::SELF, {packets:[{type: 'inventory', weight: carrier.weight, list: 'remove', items: [object_id]}]}.to_json
			end
		end
		alias :dispel :despawn
	end
end