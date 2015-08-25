module Behaviour
	module Movable
		def move?(destination)
			move = Intent::Move.new self, destination
			move.traversible? && move.adjacent? && move.possible?
		end

		def move(destination)
			move = Intent::Move.new self, destination
			if move.traversible? && move.adjacent? && move.possible?
				move.apply_costs
				z_delta = destination.z - self.location.z
				if self.location.x == destination.x && self.location.y == destination.y && z_delta.abs == 1
					if z_delta > 0
						msg = "You step inside #{destination.name}."
						msg_type = MessageType::STEP_INSIDE
					else
						msg = "You step outside of #{self.location.name}."
						msg_type = MessageType::STEP_INSIDE
					end
					message_mov = Entity::Message.new({characters: [self.id], message: msg, type: msg_type})
					message_mov.save
				end
				move! destination
			end
		end

		def move!(destination)
			self.location = destination
			self.broadcast_self BroadcastScope::TILE
		end

	end
end
