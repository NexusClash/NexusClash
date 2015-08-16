require 'autoinc'
module Entity
	class TileType
		include Mongoid::Document
		include Unobservable::Support
		include Mongoid::Autoinc

		field :id, type: Integer
		increments :id

		field :name, type: String
		field :description, type: String
		field :colour, type: String

		@@types = ThreadSafe::Cache.new do |hash, typeident|
			if Entity::TileType.where({id: typeident}).exists? then
				eff = Entity::TileType.find_by({id: typeident})
				hash[typeident] = eff
			else
				Entity::VoidTileType
			end
		end

		def self.find(type)
			type = type.to_i
			if type == -1
				Entity::VoidTileType
			else
				@@types[type]
			end
		end

		def traversible?
			true
		end

		def self.load_types
			TileType.each do |type|
				@@types[type.id] = type
			end
		end

		def to_s
			self.name
		end
	end
end