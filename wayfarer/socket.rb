module Wayfarer
	class Socket

		@@list = ThreadSafe::Cache.new

		@@inc = 1

		def self.add(socket)
			socket.identifier = @@inc
			@@list[@@inc] = socket
			@@inc += 1
		end

		def self.fetch(id)
			return @@list.fetch(id.to_i, nil)
		end

	end
end