require 'autoinc'
module Entity
	class ItemType
		include Mongoid::Document
		include Unobservable::Support
		include Mongoid::Autoinc
		include IndefiniteArticle

		field :id, type: Integer
		#increments :id

		field :name, type: String
		field :category, type: Symbol
		field :weight, type: Integer, default: 0
		field :giveable?, type: Boolean, default: true

		field :statuses, type: Array, default: []

		@@types = ThreadSafe::Cache.new do |hash, typeident|
			if Entity::ItemType.where({id: typeident}).exists? then
				eff = Entity::ItemType.find_by({id: typeident})
				hash[typeident] = eff
			else
				InvalidItemType
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

		after_find do |document|
			(statuses << Effect::Giveable.status_type_id) if giveable? && !statuses.include?(Effect::Giveable.status_type_id)
		end

		def self.load_types
			ItemType.each do |type|
				@@types[type.id] = type
			end
		end

		def self.reload_types
			@@types.keys.each do |k|
				@@types[k].reload
			end
		end

		def to_s
			self.name
		end

		class InvalidItemType
			def self.d
				-1
			end

			def self.name
				'Invalid Item - Bug Report Please!'
			end

			def self.category
				:mundane
			end

			def self.statuses
				[]
			end

			def self.weight
				0
			end
		end
	end
end
