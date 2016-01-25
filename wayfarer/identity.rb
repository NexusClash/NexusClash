module Wayfarer
	module Identity

		attr_accessor :user
		attr_accessor :character
		attr_accessor :identifier
		attr_accessor :target
		attr_accessor :admin

#		#def character=(char)
#		#	@character = char
#
#			packets = []
#			packets << {type: 'character', character: char.to_hash}
#			data = {packets: packets}
#			self.send data.to_json
#		end

	end
end