module Effect
	class Ammo

		attr_reader :ammo_type
		attr_reader :capacity

		def initialize(parent, ammo_type, capacity)
			@parent = parent
			@ammo_type = ammo_type.to_sym
			@capacity = capacity.to_i
		end

		def describe
			"Reloads weapons using #{ammo_type.to_s}s with #{capacity} ammo."
		end

		def save_state
			['Ammo', @ammo_type, @capacity]
		end
	end
end