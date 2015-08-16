class Dash < Sinatra::Application
	get '/game/:id' do
		protected!

		session[:connecting_char_id] = params[:id]
		token = SecureRandom.hex
		Entity::Account.where(username: @user.username).update(authentication_token: token)

		haml :'game/index', :layout => :'layouts/game', :locals => {:char_id => params[:id], :token => token}
	end
end