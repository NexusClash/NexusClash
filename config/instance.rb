DB_PERSIST_DELAYED = 2
DB_PERSIST_IMMEDIATE = 1

class Instance
	def self.plane
		1
	end

	def self.domain
		'ruby.windrunner.mx'
	end

	def self.port
		4567
	end

	def self.show_exceptions
		true
	end

	def self.endpoint
		'ws://ruby.windrunner.mx:4020/42'
	end

	@@debug = true

	def self.debug
		@@debug
	end

	def self.debug=(val)
		@@debug = val
	end
end

DB_PERSIST_MODE = DB_PERSIST_IMMEDIATE