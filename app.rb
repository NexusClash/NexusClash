require 'bundler'
require 'observer'
#require 'opal/browser'
require 'json'
require 'securerandom'
require 'faye/websocket'
require 'websocket/extensions'
require 'permessage_deflate'
require 'tilt/haml'
Bundler.require
require 'digest/sha1'

puts 'Loading base system...'

Mongoid.load!('mongoid.yml')

require_rel 'enums'
require_rel 'config'
require_rel 'behaviour/core'
require_rel 'behaviour/intent/generic'
require_rel 'behaviour/intent'
require_rel 'behaviour/effect/generic'
require_rel 'behaviour/effect'
require_rel 'mixins'
require_rel 'controllers'
require_rel 'models'
require_rel 'firmament/entities'
require_rel 'firmament'
require_rel 'wayfarer'
require_rel 'datatables'

require 'rack/session/abstract/id'
require 'thread'

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
	use Rack::Session::UnifiedPool, :domain => Instance.domain, :expire_after => 60 * 60 * 24 * 365 # TODO: Add secret
end

puts 'Loading game type definitions...'

Entity::StatusType.load_types

Entity::TileType.load_types

Firmament::Plane.new Instance.plane


Faye::WebSocket.load_adapter('puma')
#use Faye::RackAdapter, :mount => '/42', :timeout => 25

class Dash < Sinatra::Application

	puts 'Sinatra loading...'

	configure { set :server, :puma
	set :views, settings.root + '/views'
	set :threaded, true
	set :environment, :production
	set :show_exceptions, Instance.show_exceptions
	}

	helpers do
		def esc(text)
			Rack::Utils.escape_html(text)
		end

		def protected!(role = nil)
			return if role === nil && auth?
			if auth?
					return if @user.roles != nil && @user.has_role?(role)
			end
			halt 401, "Not authorized\n"
		end

		def role?(role = nil)
			return false unless auth?
			return true if @user.roles != nil && @user.has_role?(role)
			return false
		end

		def auth?
			session[:username] != nil
		end
	end

	before do
		if session[:username] === nil then
			@logged_in = false
			@layout = :'layouts/guest'
		else
			if Entity::Account.where({username: session[:username]}).exists?
				@user = Entity::Account.find_by({username: session[:username]})
				@logged_in = true
				@layout = :'layouts/user'
			else
				session[:username] = nil
				@logged_in = false
				@layout = :'layouts/guest'
			end
		end

	end
end


get '/' do

	# Collate interesting events for homepage

	#todo: Better way of storing interesting messages

	intro_class = ['Holy Champion', 'Lich', 'Corruptor', 'Seraph', 'Nexus Champion', 'Infernal Behemoth']

	events = []

	Entity::Message.where({type: MessageType::CLASS_LEARNT}).desc('_id').limit(5).each do |msg|

		ele = msg.message.split(' has become a ')
		ele[1].chomp! '!'

		events << {header: "#{ele[0]} became a #{ele[1]}", time: Time::at(msg.timestamp.to_i).strftime('%Y-%m-%d %H:%M:%S'), background: ele[1], body:"<a class='ui-button' href='/character/#{ele[0]}'>View Profile</a> <a class='ui-button' href='/wiki/#{ele[1]}'>Learn About #{ele[1]}s</a>"}
	end

	while events.count < 5 do
		events.unshift({header: '', time: '', background: intro_class[rand(1..(intro_class.count)) - 1], body: ''})
	end

	haml :home, :layout => @layout, :locals => {:slides => events, :message => '<h1>Welcome to Nexus Clash!</h1><p>Welcome to the B4 Alpha!<br/><br/>Nexus Clash is a browser-based MMORPG that continues the saga of Nexus War. Each character in the game is a soul entrapped in this eternal struggle that rages across worlds. Characters can choose to become fearsome Demons, mighty Wizards, powerful warriors, or even Angels - and every action is measured in the scales of reality to determine what new worlds will be formed in each new Breath of Creation.</p>'}
end

server = 'puma'
host = '127.0.0.1'
port = ENV['OS'] == 'Windows_NT' ? '80' : Instance.port
web_app = Dash.new


ws_app = lambda do |env|


	Faye::WebSocket.send :include, Wayfarer::Engine


	ws = Faye::WebSocket.new(env, ["nexusdash"], {:ping => 25, :extensions => [PermessageDeflate]})

	Wayfarer::Socket.add ws

	ws.on :message do |event|
		begin
			msg = JSON(event.data)

			session = env['rack.session']

			msg['packets'].each do |ent|
				if ent['type'] == 'connect'
					# Authenticate as plane server
					if ent.has_key? 'plane'
						plane = Entity::Plane.where(plane: ent['plane']).first
						if plane.token == ent['token']
							ws.plane = plane.id
							Firmament::Plane.add_server ws
						end
					end
					# Authenticate as admin
					if ent.has_key? 'admin'
						user = Entity::Account.where(username: session[:username]).first
						if user.has_role?(:admin)
							ws.send({packets: [{type: 'developer_mode', toggle: 'on' }]}.to_json)
							ws.admin = true
							Firmament::Plane.add_admin ws
						else
							ws.send({packets: [{type: 'error', message: 'Authentication failiure' }]}.to_json)
						end
					end
					# Authenticate as character
					if ent.has_key? 'char_id'
						game = Firmament::Plane.fetch Instance.plane
						if game.character? ent[:char_id]
							char = game.character ent[:char_id]
						else
							char = Entity::Character.find(ent['char_id'].to_i)
						end
						unless char.plane === Instance.plane
							ws.send({packets: [{type: 'error', message: 'Connected to wrong plane server for character!' }]}.to_json)
							return
						end
						if char != nil
							if char.account.username == session[:username]
								ws.character = game.character ent['char_id'].to_i
								ws.character.socket.send({packets: [{type: 'debug', message: 'Another login has deregistered this character from this connection!'}]}) unless ws.character.socket === nil
								ws.character.socket = ws
								ws.admin = char.account.has_role?(:admin)
								ws.send({packets: [{type: 'self', character: ws.character.to_hash }, {type: 'developer_mode', toggle: ( ws.admin ? 'on' : 'off' )}]}.to_json)
							else
								ws.send({packets: [{type: 'error', message: 'Authentication failiure' }]}.to_json)
							end
						else
							ws.send({packets: [{type: 'error', message: 'Authentication failiure' }]}.to_json)
						end
					end
				else
					type = ent['type'].to_sym
					if Wayfarer::Engine.api_functions.include? type
						ws.__send__(type, ent) unless ws.character === nil && ws.admin != true
					else
						ws.send({packets: [{type: 'debug', message: "Invalid API Call: #{type}. Valid Wayfarer API calls are: #{Wayfarer::Engine.api_functions.to_a.join(', ')}." }]}.to_json)
					end
				end
			end

		rescue JSON::ParserError => ex
			puts "D: You call that JSON? #{ex}"
			ws.send({packets: [{type: 'debug', message: 'Invalid JSON' }]}.to_json)
		rescue Exception => e
			trace = e.backtrace
			trace_hash = Digest::SHA1.hexdigest trace.inspect
			err_msg = Entity::Message.new({characters: [], message: "REF: ##{trace_hash} BACKTRACE: #{trace.inspect}", type: MessageType::BACKTRACE})
			err_msg.save
			unless ws.character === nil
				err_msg = Entity::Message.new({characters: [ws.character.id], message: "<b>Nexus Clash has encountered an error!</b><br/><b>Exception:</b> #{e.message}<br/><b>Backtrace Reference ##{trace_hash}</b><br/><b><u>Please report this issue on the forums.</u></b>", type: MessageType::ERROR})
				err_msg.save
			end
			ws.send({packets: [{type: 'error', message: e.message + '<br/>' + trace[0..([trace.length / 2, 3].min)].inspect }]}.to_json)
		end
	end

	ws.on :error do |event|
		puts event.inspect
	end

	ws.on :close do |event|
		#ws.character = nil
		#Dimension::SocketHandler.remove_socket(ws)
		ws.character.socket = nil unless ws.character === nil
		Firmament::Plane.remove_admin(ws) if ws.admin
		ws = nil
	end

	ws.send({packets: [{type: 'authentication_request'}]}.to_json)


	ws.rack_response

end


opal = Opal::Server.new {|s|
	s.append_path 'opal'
	s.append_path 'enums'
	s.append_path 'config'
	s.main = 'zapdash'
}


ws_app_sessioned = Rack::Session::UnifiedPool.new(ws_app, :domain => Instance.domain, :expire_after => 60 * 60 * 24 * 365)


dispatch = Rack::Builder.app do
	map '/' do
		run web_app
	end
	map '/42' do
		run ws_app_sessioned
	end
	map '/rb' do
		run opal.sprockets
	end
	#map opal.source_maps.prefix do
	#	run opal.source_maps
	#end
end

Rack::Server.start({
		                   app: dispatch,
		                   server: server,
		                   Host: host,
		                   Port: port
                   })

puts 'All started!'