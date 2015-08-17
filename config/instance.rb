require 'rack/session/abstract/id'
require 'thread'

class Instance
	def self.plane
		1
	end

	def self.domain
		'ruby.windrunner.mx' #also needs changing in zapdash.rb
	end
end

module Rack
	module Session
		# Rack::Session::Pool provides simple cookie based session management.
		# Session data is stored in a hash held by @pool.
		# In the context of a multithreaded environment, sessions being
		# committed to the pool is done in a merging manner.
		#
		# The :drop option is available in rack.session.options if you wish to
		# explicitly remove the session from the session cache.
		#
		# Example:
		#   myapp = MyRackApp.new
		#   sessioned = Rack::Session::Pool.new(myapp,
		#     :domain => 'foo.com',
		#     :expire_after => 2592000
		#   )
		#   Rack::Handler::WEBrick.run sessioned

		class UnifiedPool < Abstract::ID

			def mutex
				@@mutex
			end

			def pool
				@@pool
			end

			DEFAULT_OPTIONS = Abstract::ID::DEFAULT_OPTIONS.merge :drop => false

			@@pool = Hash.new
			@@mutex = Mutex.new

			def initialize(app, options={})
				super
			end

			def generate_sid
				loop do
					sid = super
					break sid unless @@pool.key? sid
				end
			end

			def get_session(env, sid)
				with_lock(env) do
					unless sid and session = @@pool[sid]
						sid, session = generate_sid, {}
						@@pool.store sid, session
					end
					[sid, session]
				end
			end

			def set_session(env, session_id, new_session, options)
				with_lock(env) do
					@@pool.store session_id, new_session
					session_id
				end
			end

			def destroy_session(env, session_id, options)
				with_lock(env) do
					@@pool.delete(session_id)
					generate_sid unless options[:drop]
				end
			end

			def with_lock(env)
				@@mutex.lock if env['rack.multithread']
				yield
			ensure
				@@mutex.unlock if @@mutex.locked?
			end
		end
	end
end


class Dash < Sinatra::Application
	use Rack::Session::UnifiedPool, :domain => Instance.domain, :expire_after => 60 * 60 * 24 * 365
end