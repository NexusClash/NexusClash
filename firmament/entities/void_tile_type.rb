module Entity
	class VoidTileType

		def self.id
			-1
		end

		def self.name
			'Void'
		end

		def self.colour
			'black'
		end

		def self.description
			''
		end

		def self.search_rate
			0
		end

		def self.hide_rate
			0
		end

		def self.search_table
			[]
		end

		def self.statuses
			[]
		end

		def traversible?
			false
		end

		def self.daytime_inside_message
			nil
		end

		def self.daytime_outside_message
			nil
		end

		def self.nighttime_inside_message
			nil
		end

		def self.nighttime_outside_message
			nil
		end

		def self.to_s
			self.name
		end

		def self.a_or_an
			'a'
		end

		def self.css
			'.tile[data-type=Void] { background-color:black; }'
		end

		def self.statuses
			[]
		end

		def self.unserialise_statuses
			# do nothing
		end
	end
end
