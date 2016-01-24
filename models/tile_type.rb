require 'autoinc'
module Entity
	class TileType
		include Mongoid::Document
		include Unobservable::Support
		include Mongoid::Autoinc
		include IndefiniteArticle

		field :id, type: Integer
		increments :id

		field :name, type: String
		field :description, type: String
		field :colour, type: String

		field :css, type: String

		field :search_rate, as: :s_rate, type: Integer, default: 0
		field :search_table, as: :s_table, type: Array, default: []

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

		def search_roll
			return rand(0..99) < self.search_rate
		end

		def search_roll_item
			rnd_max = self.search_table.inject(0) { |sum, itm| sum + itm[1] }
			return nil unless rnd_max > 0

			roll = rand(1..rnd_max)

			self.search_table.each do |possibility|
				roll -= possibility[1]
				return Entity::Item.source_from(possibility[0]) unless roll > 0
			end

			return nil
		end

		def traversible?
			true
		end

		def self.purge_cache
			@@types.clear
		end

		def self.load_types
			TileType.each do |type|
				@@types[type.id] = type
			end
		end

		def to_s
			self.name
		end

		after_find do |document|
			document.search_table = [] if document.search_table === nil
		end
		after_initialize do |document|
			document.search_table = [] if document.search_table === nil
		end
	end
end