module Intent
	class ActivateAbilitySelf < ActivateSelf
		def take_action
			super
			@entity.broadcast_self Entity::Status.tick(@target, StatusTick::ACTIVATED)
		end
	end
end
