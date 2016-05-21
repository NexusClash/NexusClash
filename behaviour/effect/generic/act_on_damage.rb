module Effect
	class ActOnDamage < Effect::ActOnTick

		def initialize(parent)
			super parent, StatusTick::DAMAGE_TAKEN
		end

		def tick_event(*_)
			return BroadcastScope::NONE
		end

		def describe
			'Whenever you take damage, '
		end

		def save_state
			[self.class.name]
		end
	end
end