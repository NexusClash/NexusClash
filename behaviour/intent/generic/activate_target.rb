module Intent
	class ActivateTarget < ActivateSelf
		attr_accessor :target_entity
		def initialize(entity, target_entity, target, effect = nil)
			super entity, target
			@target_entity = target_entity
			unless effect === nil
				effect.activate_target_intent self
			end
		end

		def take_action
			super
			@entity.broadcast_self Entity::Status.tick(@target, StatusTick::ACTIVATED)
			@target_entity.broadcast_self Entity::Status.tick(@target, StatusTick::ACTIVATED_TARGET, @target_entity)
		end
	end
end
