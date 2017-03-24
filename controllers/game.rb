class Dash < Sinatra::Application
	get '/game/:id' do
		protected!

		session[:connecting_char_id] = params[:id]
		token = SecureRandom.hex
		Entity::Account.where(username: @user.username).update(authentication_token: token)

		char = Entity::Character.where(id: params[:id].to_i).first

		if char.plane == Instance.plane
			haml :'game/index', :layout => :'layouts/game', :locals => {:char_id => params[:id], :token => token}
		else
			#Divert to appropriate plane
			plane = Entity::Plane.where({plane: char.plane}).first
			redirect to("https://#{plane.domain}/warp/#{@user.username}/#{char.id}/#{token}/game")
		end
	end

	get '/css/tile' do
		packets = Entity::TileType.all.map(&:css).join("\n")
	end
end
