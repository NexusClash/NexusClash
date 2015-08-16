module Intent
	class Move
		attr_accessor :entity
		attr_accessor :start
		attr_accessor :end
		attr_accessor :costs
		attr_accessor :message

		def initialize(entity, destination)
			@entity = entity
			@start = entity.location
			@end = destination
			@costs = Hash.new{|hash, key| hash[key] = 0}
			@costs[:ap] = 1 unless @start == @end
			@message = ''
		end

		def apply_costs
			@entity.ap -= @costs[:ap] unless @costs[:ap] == 0
			@entity.mp -= @costs[:mp] unless @costs[:mp] == 0
			@entity.hp -= @costs[:hp] unless @costs[:hp] == 0
			@entity.mo -= @costs[:mo] unless @costs[:mo] == 0
		end

		def possible?
			costs = @costs.clone
			result = @entity.ap >= @costs[:ap] && @entity.mp >= @costs[:mp]
			@costs = costs
			return result
		end

		def traversible?
			@end.traversible?
		end

		def adjacent?
			dx = @start.x - @end.x
			dy = @start.y - @end.y
			dz = @start.z - @end.z

			(dx.between?(-1,1) && dy.between?(-1,1) && dz == 0 && dx.abs + dy.abs > 0) || ((dx == 0 && dy == 0 && dz.abs == 1))
		end
	end
end
