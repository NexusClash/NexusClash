module Entity
	class Status
		def dispel
			if DB_PERSIST_MODE === DB_PERSIST_DELAYED
				self.stateful.remove_child self
				self.stateful.shard.pending_deletion << self
			else
				self.destroy
			end
		end
		alias :despawn :dispel
	end
end