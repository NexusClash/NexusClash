require 'autoinc'
module Entity
	class ItemType
		include Mongoid::Document
		include Unobservable::Support
		include Mongoid::Autoinc

		field :id, type: Integer
		increments :id

		field :name, type: String
		field :category, type: Symbol
		field :weight, type: Integer, default: 0

		field :statuses, type: Array, default: []

		@@types = ThreadSafe::Cache.new do |hash, typeident|
			if Entity::ItemType.where({id: typeident}).exists? then
				eff = Entity::ItemType.find_by({id: typeident})
				hash[typeident] = eff
			else
				nil
			end
		end

		def self.find(type)
			type = type.to_i
			if type == -1
				nil
			else
				@@types[type]
			end
		end

		def self.load_types
			ItemType.each do |type|
				@@types[type.id] = type
			end
		end

		def to_s
			self.name
		end
	end
end