class Dash < Sinatra::Application
	get '/character/:id' do

		id = params[:id].to_i

		game = Firmament::Plane.fetch Instance.plane

		layout = :'layouts/guest'
		layout = :'layouts/user' if auth?

		if id == 0
			char = Entity::Character.where({name: params[:id]}).first
			id = char.id unless char === nil
		else
			if game.character? id
				char = game.character id
			else
				char = Entity::Character.where({id: id}).first
			end

		end

		return haml :'character/none', :layout => layout if char === nil

		if char.plane == Instance.plane

			char = game.character id


			# Calculate skill tree

			root = char.skill_tree false


			owner = false
			owner = true if auth? && @user.id == char.account.id

			haml :'character/profile', :layout => layout, :locals => {:auth => auth?, :char => char, :skills => root, :owner => owner}
		else
			#Divert to appropriate plane
			plane = Entity::Plane.where({plane: char.plane}).first
			if auth?
				token = SecureRandom.hex
				Entity::Account.where(username: @user.username).update(authentication_token: token)
				redirect to("https://#{plane.domain}/warp/#{@user.username}/#{char.id}/#{token}/character")
			else
				redirect to("https://#{plane.domain}/character/#{char.id}")
			end
		end
	end

	post '/character/:id' do
		protected!

		char = Entity::Character.where({id: params[:id].to_i}).first

		errors = []
		errors << 'Wrong owner for character!' unless @user.id == char.account.id
		unless errors.count > 0 then
			Entity::Character.where(id: params[:id]).update(gender: params[:gender].to_i)
			game = Firmament::Plane.fetch Instance.plane
			if game.character? params[:id]
				char = game.character params[:id]
				char.gender = params[:gender].to_i
			end
		end
		redirect to("/character/#{params[:id]}")
	end
end