module Entity
	class Plane
		include Mongoid::Document

		field :plane, type: Integer
		field :name, type: String
	end
end