module Effect
	class Base

		def self.unserialize(parent, object)
			object = object.clone
			type = object.shift
			object.unshift(parent)
			type = Effect.const_get type
			type.new *object
		end

		def self.effect_list
			Foo.constants.select {|c| Foo.const_get(c).is_a?(Class) && c != :Base}
		end
	end
end