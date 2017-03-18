module Entity
	class Plane
		include Mongoid::Document

		field :plane, type: Integer
		field :name, type: String

		field :domain, type: String
		field :ws_port, type: String
		field :token, type: String

		field :daytime_inside_message, type: String
		field :daytime_outside_message, type: String
		field :nighttime_inside_message, type: String
		field :nighttime_outside_message, type: String
	end
end
