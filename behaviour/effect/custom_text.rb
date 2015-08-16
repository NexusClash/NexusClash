module Effect
	class CustomText < Effect::Base

		def initialize(parent, text)
			@parent = parent
			@text = text
		end

		def describe
			@text
		end

		def save_state
			['CustomText', @text]
		end
	end
end