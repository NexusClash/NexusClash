require 'bundler'
require 'observer'
#require 'opal/browser'
require 'json'
require 'securerandom'
require 'faye/websocket'
require 'websocket/extensions'
require 'permessage_deflate'
Bundler.require

puts 'Loading base system...'

Mongoid.load!('mongoid.yml')

require_rel 'enums'
require_rel 'config'
require_rel 'behaviour/core'
require_rel 'behaviour/intent'
require_rel 'behaviour/effect'
require_rel 'mixins'
require_rel 'controllers'
require_rel 'models'
require_rel 'firmament/entities'
require_rel 'firmament'
require_rel 'wayfarer'
require_rel 'datatables'

DB_PERSIST_MODE = DB_PERSIST_IMMEDIATE

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
	haml :index, :layout => @layout
end

server = 'puma'
host = '0.0.0.0'
port = ENV['OS'] == 'Windows_NT' ? '80' : '4567'
web_app = Dash.new


ws_app = lambda do |env|

	Faye::WebSocket.send :include, Wayfarer::Identity


	ws = Faye::WebSocket.new(env, ["nexusdash"], {:ping => 25, :extensions => [PermessageDeflate]})

	Wayfarer::Socket.add ws

	ws.on :message do |event|
		begin
			msg = JSON(event.data)

			session = env['rack.session']

			msg['packets'].each do |ent|
				case ent['type'].to_s
					when 'request_character'
						ws.send({packets: [{type: 'character', character: ws.character.to_hash}]}.to_json)
					when 'connect'
						char = Entity::Character.find(ent['char_id'].to_i)
						if char.account.username == session[:username]
							game = Firmament::Plane.fetch Instance.plane
							ws.character = game.character ent['char_id'].to_i
							ws.character.socket.send({packets: [{type: 'debug', message: 'Another login has deregistered this character from this connection!'}]}) unless ws.character.socket === nil
							ws.character.socket = ws
							ws.send({packets: [{type: 'self', character: ws.character.to_hash }, {type: 'developer_mode', toggle: ( char.account.has_role?(:admin) ? 'on' : 'off' )}]}.to_json)
						else
							ws.send({packets: [{type: 'error', message: 'Authentication failiure' }]}.to_json)
						end
					else
						Wayfarer.process_message(ws, ent) unless ws.character === nil
				end
			end

		rescue JSON::ParserError => ex
			puts "D: You call that JSON? #{ex}"
			ws.send({packets: [{type: 'debug', message: 'Invalid JSON' }]}.to_json)
		rescue Exception => e
			ws.send({packets: [{type: 'debug', message: e.message + '\n' + e.backtrace.inspect }]}.to_json)
		end
	end

	ws.on :error do |event|
		puts event.inspect
	end

	ws.on :close do |event|
		#ws.character = nil
		#Dimension::SocketHandler.remove_socket(ws)
		ws.character.socket = nil unless ws.character === nil
		ws = nil
	end

	ws.send({packets: [{type: 'authentication_request'}]}.to_json)


	ws.rack_response

end


opal = Opal::Server.new {|s|
	s.append_path 'opal'
	s.main = 'opal/zapdash'
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
	map opal.source_maps.prefix do
		run opal.source_maps
	end
end

Rack::Server.start({
		                   app: dispatch,
		                   server: server,
		                   Host: host,
		                   Port: port
                   })

puts 'All started!'