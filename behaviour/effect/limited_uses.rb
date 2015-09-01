module Effect
	class LimitedUses

		#TODO: Support multiple uses

		def initialize(parent, uses = 1)
			@parent = parent
			@uses = uses.to_i
		end

		def tick_item_activation(target)
			target.despawn
			return BroadcastScope::NONE
		end

		def describe
			"Destroy this after being used #{@uses.to_s} #{@uses == 1 ? 'time' : 'times'}."
		end

		def save_state
			['LimitedUses', @uses]
		end
	end
end