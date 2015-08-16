module Entity
	class Message
		include Mongoid::Document

		field :timestamp, type:Time, default: ->{Time.now}
		field :characters, type:Array
		field :message, type:String
		field :type, type:Symbol

		scope :character, ->(char_id){ where(:characters.in => [char_id]) }
		scope :from, ->(from){ where(:timestamp.gt => from) }
		scope :character_from, ->(char_id, from){ where(:characters.in => [char_id], :timestamp.gt => from) }
	end
end