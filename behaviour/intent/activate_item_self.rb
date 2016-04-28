module Intent
	class ActivateItemSelf < ActivateSelf
		def take_action
			super
			@entity.broadcast_self Entity::Status.tick(@target, StatusTick::ITEM_ACTIVATED)
		end
	end
end
