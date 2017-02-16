module Entity
	class StatusType
		include Mongoid::Document
		include Mongoid::Autoinc
		include IndefiniteArticle

		field :id, type: Integer
		#increments :id

		field :name, type: String

		field :family, type: Symbol

		field :impacts, type: Array, default: []

		#field :locked, type: Boolean

		field :activation, type: Symbol, default: :standard

		@@types = ThreadSafe::Cache.new do |hash, typeident|
			if Entity::StatusType.where({id: typeident}).exists? then
				eff = Entity::StatusType.find_by({id: typeident})
				hash[typeident] = eff
			else
				InvalidStatusType
			end
		end

		@@skills = ThreadSafe::Array.new
		@@classes = ThreadSafe::Array.new

		def self.find(type)
			@@types[type.to_i]
		end

		def self.types
			@@types.values
		end

		def self.skills
			@@skills
		end

		def self.classes
			@@classes
		end

		def describe(flatten = nil)
			desc = []
			self.impacts.each do |impact|
				desc << Effect::Base.unserialize(self, impact).describe
			end
			return desc.join(flatten) unless flatten === nil
			desc
		end

		def self.purge_cache
			@@types.clear
			@@skills.clear
			@@classes.clear
		end

		def self.load_types
			StatusType.each do |type|
				@@types[type.id] = type
				@@skills << type if type.family.to_sym == :skill
				@@classes << type if type.family.to_sym == :class
			end
		end

		class InvalidStatusType
			def self.name
				'Invalid'
			end
			def self.family
				:invalid
			end
			def self.impacts
				[]
			end

			def self.id
				0
			end
		end

	end
end
