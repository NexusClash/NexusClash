class Dash < Sinatra::Application
	get '/account/login' do
		haml :'account/login', :layout => @layout
	end

	get '/account/socket/authenticate/:socket' do
		socket = Wayfarer::Socket.fetch(params[:socket])
		if socket then
			if socket.character then
				if socket.character.id != session[:connecting_char_id] then
					socket.send({packets: [{type: 'error', message: 'Different character already attached to socket!'}]}.to_json)
					return
				end
			end
			if socket.user then
				if socket.user != session[:user] then
					socket.send({packets: [{type: 'error', message: 'Different account already attached to socket!'}]}.to_json)
					return
				end
			end
			socket.user = session[:user]

			game = Firmament::Plane.fetch Instance.plane

			character = game.character session[:connecting_char_id]

			if character.account.id == socket.user.id then
				socket.character = character
			else
				socket.send({packets: [{type: 'error', message: 'Requested character does not belong to account!'}]}.to_json)
				return
			end

			puts "Authenticated socket ##{params[:socket]} as character ##{socket.character.id} (#{socket.character.name})"
			socket.send({packets: [{type: 'character', character: socket.character.to_hash}]}.to_json)

		else
			puts "Attempt to authenticate without socket (##{params[:socket]}) detected :("
		end
	end

	post '/account/login' do
		if Entity::Account.where(username: params[:username]).exists? then
			user = Entity::Account.where(username: params[:username]).first
			if user.password? params[:password] then
				session[:username] = user.username
				redirect to('/account/characters')
			else
				haml :'account/login', :layout => @layout, :locals => {:errors => [ "Incorrect password" ]}
			end
		else
			haml :'account/login', :layout => @layout, :locals => {:errors => [ "Invalid username" ]}
		end
	end


	get '/account/register' do
		haml :'account/register', :layout => @layout
	end

	post '/account/register' do
		errors = []
		errors << 'Username required' unless params[:username].length > 0
		errors << 'Username already taken' if Entity::Account.where(username: params[:username]).exists?
		errors << 'Password required' unless params[:password].length > 0

		if errors.count > 0 then
			haml :'account/register', :layout => @layout, :locals => {:errors => errors}
		else
			account = Entity::Account.new do |acc|
				acc.username = params[:username]
				acc.password = params[:password]
			end
			account.save
			session[:username] = account.username
			redirect to('/account/characters')
		end
	end

	get '/account/characters' do
		protected!

		characters_updated = Array.new

		@user.characters.each do |char|
			plane = Firmament::Plane.fetch char.plane
			if plane.character? char.id
				characters_updated << plane.character(char.id)
			else
				characters_updated << char
			end
		end

		haml :'account/characters', :layout => @layout, :locals => {:characters => characters_updated}
	end

	get '/account/characters/create' do
		protected!
		haml :'account/characters_create', :layout => @layout
	end


	post '/account/characters/create' do
		protected!
		errors = []
		errors << 'Character name required' unless params[:charname].length > 0
		errors << 'Character name already taken' if Entity::Character.where(name: params[:charname]).exists?
		if errors.count > 0 then
			haml :'account/characters/create', :layout => @layout, :locals => {:errors => errors}
		else
			newchar = Entity::Character.new(name: params[:charname])
			newchar.statuses << Entity::Status.source_from(1)
			@user.characters << newchar
			# Push existence to game map
			game = Firmament::Plane.fetch Instance.plane
			newchar = game.character newchar.id
			newchar.update_location newchar.location, newchar.location
			redirect to('/account/characters')
		end
	end

	get '/account/logout' do
		protected!
		session.delete :user
		session.delete :username

		redirect to('/')
	end

	get '/validate/:id' do
		protected!

		char = Entity::Character.find(params[:id].to_i)
		if char.account.username == session[:username]
			'ok'
		else
			'no'
		end
	end

end