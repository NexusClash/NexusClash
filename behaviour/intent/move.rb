module Intent
	class Move < Action
		attr_accessor :entity
		attr_accessor :start
		attr_accessor :end
		attr_accessor :costs
		attr_accessor :message

		def initialize(entity, destination)
			super entity
			@start = entity.location
			@end = destination
			@message = ''
			add_cost :ap, 1
		end

		def possible?
			debug "Able? #{super ? 'Yes' : 'No'} Traversible? #{traversible? ? 'Yes' : 'No'} Adjacent? #{adjacent? ? 'Yes' : 'No'} Movement? #{@start != @end ? 'Yes' : 'No'}" if Instance.debug
			super && traversible? && adjacent? && @start != @end
		end

		def traversible?
			@end.traversible?
		end

		def adjacent?
			dx = @start.x - @end.x
			dy = @start.y - @end.y
			dz = @start.z - @end.z

			(dx.between?(-1,1) && dy.between?(-1,1) && dz == 0 && dx.abs + dy.abs > 0) || ((dx == 0 && dy == 0 && dz.abs == 1))
		end

		def take_action
			#TODO: move logic in move! into here and out of Entity::Character
			@entity.move! @end
		end

		def broadcast_results
			z_delta = @end.z - @start.z
			if @start.x == @end.x && @start.y == @end.y && z_delta.abs == 1
				if z_delta > 0
					msg = "You step inside #{@end.name}."
					msg_type = MessageType::STEP_INSIDE
				else
					msg = "You step outside of #{@start.name}."
					msg_type = MessageType::STEP_OUTSIDE
				end
				message_mov = Entity::Message.new({characters: [@entity.id], message: msg, type: msg_type})
				message_mov.save
			end
		end
	end
end
