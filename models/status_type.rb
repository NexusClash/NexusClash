module Entity
	class StatusType
		include Mongoid::Document
		include Mongoid::Autoinc

		field :id, type: Integer
		increments :id

		field :name, type: String

		field :family, type: Symbol

		field :impacts, type: Array, default: []

		#field :locked, type: Boolean

		field :activation, type: Symbol, default: :standard

		@@types = ThreadSafe::Cache.new do |hash, typeident|
			if Entity::StatusType.where({id: typeident}).exists? then
				eff = Entity::StatusType.find_by({id: typeident})
				hash[typeident] = eff
			end
		end

		@@skills = ThreadSafe::Array.new

		def self.find(type)
			@@types[type.to_i]
		end

		def self.skills
			@@skills
		end

		def describe(flatten = nil)
			desc = []
			self.impacts.each do |impact|
				desc << Effect::Base.unserialize(self, impact).describe
			end
			return desc.join(flatten) unless flatten === nil
			desc
		end

		def self.load_types
			StatusType.each do |type|
				@@types[type.id] = type
				@@skills << type if type.family.to_sym == :skill
			end
		end

	end
end