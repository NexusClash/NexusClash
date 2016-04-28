class Dash < Sinatra::Application
	get '/character/:id' do

		if params[:id].to_i == 0
			char = Entity::Character.where({name: params[:id]}).first
		else
			char = Entity::Character.where({id: params[:id].to_i}).first
		end

		return haml :'character/none', :layout => layout if char === nil

		if char.plane == Instance.plane

			game = Firmament::Plane.fetch Instance.plane
			char = game.character params[:id]


			# Calculate skill tree

			root = Array.new

			nodes_added = 0

			char.statuses.each do |status|
				if status.family == :class
					nodes_added += 1
					root << {id: status.link, name: status.name, type: :class, learned: true, children: []}
				end
			end

			add_to_tree = lambda do |tree, item, prereq; pinpoint, found, children, found2|
				pinpoint = tree.index{|esrc| esrc[:id] == prereq}
				found = false
				if pinpoint === nil
					tree.map! { |ele|
						children, found2 = add_to_tree.call(ele[:children], item, prereq)
						ele[:children] = children if found2
						found = found || found2
						ele
					}
				else
					tree[pinpoint][:children] << item
					found = true
				end
				return tree, found
			end

			skips = []

			char.statuses.each do |instance_skill|
				if instance_skill.family == :skill
					instance_skill.effects.each do |effect|
						if effect.is_a?(Effect::SkillPrerequisite)
							tree, node_add = add_to_tree.call(root, {id: instance_skill.link, name: instance_skill.name, description: instance_skill.describe, type: instance_skill.family, learned: true, cost: 0, children: []}, effect.link.id)
							root = tree if node_add
							skips << instance_skill.link
						end
					end
				end
			end


			root = [root] unless root.is_a? Array


			owner = false
			owner = true if auth? && @user.id == char.account.id

			layout = :'layouts/guest'
			layout = :'layouts/user' if auth?

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