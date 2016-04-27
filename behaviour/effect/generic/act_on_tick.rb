module Effect
	class ActOnTick < Effect::Base

		def initialize(parent, interval)
			@interval = interval
			@parent = parent

			define_singleton_method ('tick_' + interval.to_s).to_sym do |target|
				tick_event target
			end
		end

		def tick_event(target)
			# do nothing, stub event
		end

		def describe
			"Each #{@interval.to_s} tick, "
		end

		def save_state
			[self.class.name, @interval] # Will take the inherited class name
		end
	end
end