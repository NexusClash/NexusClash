module Effect
	class Duration

		def initialize(parent, max_duration = 1, type = StatusTick::STATUS)
			@parent = parent
			@max_duration = max_duration.to_i
			@type = type

			@parent.set_tag :duration, @max_duration

			define_singleton_method ('tick_' + type.to_s).to_sym do |target|

				duration = @parent.get_tag(:duration)
				duration = @max_duration if duration === nil
				duration = duration.to_i
				duration -= 1
				@parent.set_tag :duration, duration
				if duration < 1
					@parent.dispel

					target = target.carrier if target.is_a? Entity::Item
					target = target.stateful if target.is_a? Entity::Status

					msg = Entity::Message.new({characters: [target.id],message: "You are no longer under the effects of #{@parent.name}.", type: MessageType::STATUS_EXPIRY})
					msg.save
				end
				return BroadcastScope::SELF
			end
		end

		def describe
			"Lasts for #{@max_duration.to_s} #{@type.to_s} #{@max_duration == 1 ? 'tick' : 'ticks'}."
		end

		def append_status_suffix
			duration = @parent.get_tag :duration
			return '' if duration === nil || duration.to_i == 0
			"(#{duration}#{@type == StatusTick::MINUTE ? 'm' : ''})"
		end

		def save_state
			['Duration', @max_duration, @type]
		end
	end
end