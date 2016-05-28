module Entity
	class Item
		include Mongoid::Document
		include Unobservable::Support
		include Entity::ObservedFields
		include Mongoid::Attributes::Dynamic

		field :name, type: String, default: nil
		field :type_id, type: Integer

		embeds_many :statuses, as: :stateful, cascade_callbacks: true

		embedded_in :carrier, polymorphic: true

		attr_accessor :type_statuses


		def get_tag(tag)
			read_attribute tag
		end

		def set_tag(tag, value)
			write_attribute tag, value
		end

		def type
			@type ||= ItemType.find self.type_id
		end

		def name
			if self[:name] === nil
				name = self.type.name
			else
				name = self[:name]
			end
			if get_tag :ammo
				return "#{name} (#{get_tag(:ammo).to_s})"
			end
			name
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

		after_initialize do |document|
		end

		before_save do |document|
		end

		after_find do |document|

			document.statuses.each do |status|
				status.unserialize
				status.parent = document
			end

			document.type_statuses = ThreadSafe::Array.new

			document.type.statuses.each do |statid|
				state = Entity::Status.source_from statid
				state.parent = document
				state.effects.each do |effect|
					effect.unseralise if effect.respond_to? :unserialise
				end
				document.type_statuses << state
			end

		end

		def self.source_from(id)
			item = Item.new
			item.type_id = id
			item.type_statuses = ThreadSafe::Array.new
			item.type.statuses.each do |statid|
				state = Entity::Status.source_from statid
				state.parent = item
				state.effects.each do |effect|
					effect.unseralise if effect.respond_to? :unserialise
				end
				item.type_statuses << state
			end
			return item
		end

		def to_h
			actions = []
			activated_uses.each do |key, use|
				actions << {name: use.name, status_id: key}
			end
			{id: self.object_id, name: self.name, type: self.type.name, category: self.type.category, weight: self.weight, actions: actions}
		end

	end
end