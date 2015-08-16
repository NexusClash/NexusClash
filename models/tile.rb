module Entity
	class Tile
		include Mongoid::Document
		include Unobservable::Support
		include Entity::ObservedFields

		field :plane, type: Integer
		field :name, type: String
		field :description, type: String
		field :type_id, type: Integer
		field :x, type: Integer
		field :y, type: Integer
		field :z, type: Integer

		index({:plane => 1, :x => 1, :y => 1, :z => 1}, :unique => true)

		def type_id=(type_id)
			self[:type_id] = type_id
			@type = Entity::TileType.find(type_id)
		end

		def type
			@type
		end

		def type=(type)
			self[:type_id] = type.id
			@type = type
		end

		def colour
			@type.colour
		end

		def description
			if self[:description] == ''
				@type.description
			else
				self[:description]
			end
		end

		def description=(name)
			if name == @type.description
				self[:description] = ''
			else
				self[:description] = name
			end
		end

		def name
			if self[:name] == ''
				@type.name
			else
				self[:name]
			end
		end

		def name=(name)
			if name == @type.name
				self[:name] = ''
			else
				self[:name] = name
			end
		end

		after_find do |document|
			document.type_id = document.type_id
		end

		#observe_fields :x, :y, :z, :plane, :name

		attr_accessor :characters

		after_initialize do |document|
			document.characters = ThreadSafe::Array.new
		end

		def traversible?
			true
		end

		def to_h
			{name: self.name, type: self.type.name, type_id: self.type_id, description: self.description, x: self.x, y: self.y, z: self.z, plane: self.plane}
		end
	end
end