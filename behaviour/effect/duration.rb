module Effect
	class Duration < Effect::ActOnTick

		attr_reader :max_duration

		def initialize(parent, max_duration = 1, interval = StatusTick::STATUS)
			super parent, interval
			@max_duration = max_duration.to_i

			duration = @parent.get_tag(:duration) if @parent.respond_to? :get_tag
			if duration === nil
				duration = @max_duration
				@parent.set_tag :duration, @max_duration if @parent.respond_to? :set_tag
			end
		end

		def tick_event(*target)
			target = super *target
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

		def describe
			"Lasts for #{@max_duration.to_s} #{@interval.to_s} #{@max_duration == 1 ? 'tick' : 'ticks'}."
		end

		def append_status_suffix
			duration = @parent.get_tag :duration
			return '' if duration === nil || duration.to_i == 0
			"(#{duration}#{@interval == StatusTick::MINUTE ? 'min' : ''})"
		end

		def save_state
			['Duration', @max_duration, @interval]
		end
	end
end