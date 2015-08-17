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

		def self.to_s
			self.name
		end
	end
end