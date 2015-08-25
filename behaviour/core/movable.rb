module Behaviour
	module Movable
		def move?(destination)
			move = Intent::Move.new self, destination
			move.traversible? && move.adjacent? && move.possible?
		end

		def move(destination)
			move = Intent::Move.new self, destination
			move.realise
		end

		def move!(destination)
			self.location = destination
			self.broadcast_self BroadcastScope::TILE
		end

	end
end
