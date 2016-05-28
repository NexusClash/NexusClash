module Effect
	class Defence

		attr_accessor :parent
		attr_reader :name
		attr_reader :soaks
		attr_reader :resistances
		attr_reader :avoidance
		attr_reader :type

		def initialize(parent, name = nil, soaks = [], resistances = [], avoidance = [], type = :bonus)
			@parent = parent
			@name = name
			@name = @parent.name if @name === nil
			@soaks = Hash.new{|hash, key| 0}
			soaks.each do |type, delta|
				@soaks[type.to_sym] = delta.to_i
			end
			@resistances = Hash.new{|hash, key| 0}
			resistances.each do |type, delta|
				@resistances[type.to_sym] = delta.to_i
			end
			@avoidance = Hash.new{|hash, key| 0}
			avoidance.each do |type, delta|
				@avoidance[type.to_sym] = delta.to_i
			end
			@type = type
		end

		def alter_damage_intent(intent)
			@soaks.each do |type, soak|
				intent.add_soak type, soak, @type
			end
			@resistances.each do |type, resistance|
				intent.add_resistance type, resistance
			end
			@avoidance.each do |type, avoid|
				intent.add_avoidance type, avoid
			end
			return intent
		end

		def describe
			stuff = ''
			@soaks.each do |type, soak|
				stuff = stuff + "#{soak.to_s} #{type.to_s} soak," unless soak == 0
			end
			@resistances.each do |type, resist|
				stuff = stuff + " #{resist.to_s}% #{type.to_s} resistance," unless resist == 0
			end

			@avoidance.each do |type, amount|
					stuff = stuff + " #{amount.to_s}% #{type.to_s} avoidance," unless amount == 0
			end

			return "#{@name.to_s} is #{@type.to_s} armour providing #{stuff.chomp(',')}."
		end

		def save_state
			if @name === @parent.name
				['Defence', nil, @soaks, @resistances, @avoidance, @type]
			else
				['Defence', @name, @soaks, @resistances, @avoidance, @type]
			end

		end

	end
end