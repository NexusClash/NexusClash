module Effect
	class Regen < Effect::Base

		def initialize(parent, interval, type, amount)
			@interval = interval
			@parent = parent
			@type = type.to_sym
			@type_max = (@type.to_s + '_max').to_sym
			@type_set = (@type.to_s + '=').to_sym
			@amount = amount.to_i

			define_singleton_method ('tick_' + interval.to_s).to_sym do |target|
				initialval = target.send @type
				val = initialval
				if @amount > 0 && target.respond_to?(@type_max) then
					max = target.send @type_max
					if val + amount > max then
						val = max if val < max
					else
						val += amount
					end
				else
					val += amount
				end
				target.send @type_set, val

				return BroadcastScope::NONE if val == initialval

				case @type
					when :ap, :xp
						return BroadcastScope::SELF
					when :hp, :mp, :mo
						return BroadcastScope::TILE
					else
						return BroadcastScope::TILE
				end
			end
		end

		def describe
			"Each #{@interval.to_s} tick, gain #{@amount.to_s} #{@type.to_s}."
		end

		def save_state
			['Regen', @interval, @type, @amount]
		end
	end
end