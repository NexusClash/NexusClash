module Entity
	class Plane
		include Mongoid::Document

		field :plane, type: Integer
		field :name, type: String

		field :domain, type: String
		field :ws_port, type: String
		field :token, type: String
	end
end
