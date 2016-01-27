module Entity
	class Portal
		include Mongoid::Document
		include Unobservable::Support
		include Entity::ObservedFields
		include IndefiniteArticle

		embedded_in :tile

		field :plane, type: Integer
		field :name, type: String
		field :description, type: String
		field :label, type: String
		field :x, type: Integer
		field :y, type: Integer
		field :z, type: Integer
		field :use_text, type: String
		field :costs, type: Hash, default: ->{Hash.new}

		#observe_fields :x, :y, :z, :plane, :name

	end
end