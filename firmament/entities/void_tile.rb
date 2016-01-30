class VoidTile
	include IndefiniteArticle

	DEAD_COORDINATE = -9001

	attr_reader :x
	attr_reader :y
	attr_reader :z
	attr_reader :plane

	def self.generate_hash(x, y, z)
		{ x: x, y: y, z: z, name: '', description: '', colour: 'black', type: 'Void', occupants: 0}
	end

	class FakeArray < Array

		def <<(ignored)
			self
		end

	end

	@@fakearray = FakeArray.new

	def initialize(p, x, y, z)
		@x = x
		@y = y
		@z = z
		@plane = p
	end

	def colour
		'black'
	end

	def type
		Entity::VoidTileType
	end

	def description
		''
	end

	def name
		''
	end

	def characters
		@@fakearray
	end

	def occupants
		@@fakearray
	end


	def traversible?
		false
	end

	def portals_packets
		[]
	end

	def save

	end

	def statuses
		[]
	end

	def type_statuses
		[]
	end

	def to_h
		{name: self.name, type: self.type.name, type_id: self.type.id, description: self.description, x: self.x, y: self.y, z: self.z, plane: self.plane}
	end
end