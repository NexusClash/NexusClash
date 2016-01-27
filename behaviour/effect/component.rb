module Effect
	class Component

		attr_reader :component

		def initialize(parent, component)
			@parent = parent
			@component = component.to_sym
		end

		def describe
			"Counts as a #{component.to_s} for crafting"
		end

		def save_state
			['Component', @component]
		end
	end
end