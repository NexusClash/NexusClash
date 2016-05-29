module Intent
	class ActivateTarget < ActivateSelf
		attr_accessor :target_entity
		def initialize(entity, target_entity, target, effect = nil)
			super entity, target
			add_cost :location_check, self.method(:location_check)
			@target_entity = target_entity
			unless effect === nil
				effect.activate_target_intent self
			end
		end

		def take_action
			super
			@entity.broadcast_self Entity::Status.tick(@target, StatusTick::ACTIVATED_SOURCE)
			@target_entity.broadcast_self Entity::Status.tick(@target, StatusTick::ACTIVATED_TARGET, @target_entity)
		end

		def location_check(action, intent)
			if action == :possible?
				intent.debug "Same location as target? #{@entity.location == @target_entity.location ? 'Yes' : 'No'}"
				@entity.location == @target_entity.location
			end
		end
	end
end
