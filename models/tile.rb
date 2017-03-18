module Entity
	class Tile
		include Mongoid::Document
		include Unobservable::Support
		include Entity::ObservedFields
		include IndefiniteArticle

		field :plane, type: Integer
		field :name, type: String
		field :description, type: String
		field :type_id, type: Integer
		field :x, type: Integer
		field :y, type: Integer
		field :z, type: Integer

		embeds_many :statuses, as: :stateful, cascade_callbacks: true

		attr_accessor :type_statuses

		embeds_many :portals

		index({:plane => 1, :x => 1, :y => 1, :z => 1}, :unique => true)

		def get_tag(tag)
			read_attribute tag
		end

		def set_tag(tag, value)
			write_attribute tag, value
		end

		def type_id=(type_id)
			self[:type_id] = type_id
			@type = Entity::TileType.find_by({tile_type_id: type_id.to_i})
			update_type_statuses
		end

		def type
			@type
		end

		def type=(type)
			self[:type_id] = type.id
			@type = type
			update_type_statuses
		end

		def colour
			@type.colour
		end

		def description
			if self[:description] === nil || self[:description] == ''
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

		def inside_tile
			1 == self.z
		end

		def custom_time_of_day_message
			current_plane = Firmament::Plane.fetch(self.plane)

			if current_plane.is_day?
				self.inside_tile ? self.type.daytime_inside_message : self.type.daytime_outside_message
			else
				self.inside_tile ? self.type.nighttime_inside_message : self.type.nighttime_outside_message
			end
		end

		def to_h
			current_plane = Firmament::Plane.fetch(self.plane)

			time_of_day_message = custom_time_of_day_message || current_plane.time_of_day_message(self.inside_tile)
			description = self.description + " " + time_of_day_message

			{name: self.name, type: self.type.name, type_id: self.type_id, description: description, colour: self.colour, x: self.x, y: self.y, z: self.z, plane: self.plane, occupants: self.visible_character_count, is_day: current_plane.is_day?}
		end

		after_initialize do |document|
			document.type_statuses = ThreadSafe::Array.new if document.type_statuses === nil
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
				document.type_statuses << state
			end

		end

		def unserialise_statuses
			update_type_statuses
			statuses.each do |s|
				s.unserialize
			end
		end

		def visible_character_count
			i = 0
			characters.each do |char|
				i += 1 if char.visibility == Visibility::VISIBLE
			end
			return i
		end

		private

		def update_type_statuses
			t_statuses = ThreadSafe::Array.new

			self.type.statuses.each do |statid|
				state = Entity::Status.source_from statid
				state.parent = self
				t_statuses << state
			end

			self.type_statuses = t_statuses
		end
	end
end
