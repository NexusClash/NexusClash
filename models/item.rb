module Entity
	class Item
		include Mongoid::Document
		include Unobservable::Support
		include Entity::ObservedFields
		include IndefiniteArticle

		field :name, type: String, default: nil
		field :type_id, type: Integer

		embeds_many :statuses, as: :stateful, cascade_callbacks: true

		embedded_in :carrier, polymorphic: true

		attr_accessor :type_statuses

		def type
			@type ||= ItemType.find self.type_id
		end

		def name
			return self[:name] unless self[:name] === nil
			self.type.name
		end

		def name=(name)
			if name == '' || name == self.type.name
				self[:name] = nil
			else
				self[:name] = name
			end
		end

		def weight
			self.type.weight
		end

		after_find do |document|

			document.statuses.each do |status|
				status.regenerate
			end

			document.type_statuses = ThreadSafe::Array.new

			document.type.statuses.each do |statid|
				state = Entity::Status.source_from statid
				document.type_statuses << state
			end

		end

		def self.source_from(id)
			item = Item.new
			item.type_id = id
			item.type_statuses = ThreadSafe::Array.new
			item.type.statuses.each do |statid|
				state = Entity::Status.source_from statid
				item.type_statuses << state
			end
			return item
		end

	end
end