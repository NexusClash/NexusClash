class Dash < Sinatra::Application

	get '/admin/status_effect' do
		protected! :admin

		haml :'admin/status_effect', :layout => :'layouts/admin', :locals => {}
	end

	get '/admin/status_effect/:id/effects' do
		protected! :admin

		status_effect = Entity::StatusType.find(params[:id].to_i)

		haml :'admin/status_effect_sub', :locals => {status: status_effect}

	end

	get '/admin/datasource/status_effect' do
		protected! :admin

		json = Array.new

		Entity::StatusType.each do |type|

			subjson = Array.new

			type.impacts.each do |impact|
				subjson << Effect::Base.unserialize(type, impact).describe
			end

			json << {id: type.id, name: type.name, family: type.family, impacts: subjson.join('<br/>')}
		end

		return {data: json}.to_json
	end

	post '/admin/editor/status_type' do
		protected! :admin

		row = params[:data]

		case params[:action]
			when 'create'
				status = Entity::StatusType.new
				status.name = row[:name]
				status.family = row[:family].to_sym
				status.activation = row[:activation].to_sym
				status.save
				row[:id] = status.id
				row[:impacts] = status.describe '<br/>'
				return {row: row}.to_json
			when 'edit'
				status = Entity::StatusType.find params[:id]
				status.name = row[:name]
				status.family = row[:family].to_sym
				status.activation = row[:activation].to_sym
				status.save
				row[:id] = status.id
				row[:impacts] = status.describe '<br/>'
				return {row: row}.to_json
			when 'remove'
				return {}.to_json
		end
	end

	get '/admin/datasource/status_effect/:status_id' do
		protected! :admin

		type = Entity::StatusType.find(params[:status_id].to_i)

		subjson = Array.new

		type.impacts.each do |impact|
			subjson << Effect::Base.unserialize(type, impact).describe
		end

		return {data: {id: type.id, name: type.name, family: type.family, impacts: subjson.join('<br/>')}}.to_json
	end

	post '/admin/editor/status_effect/:sid/effects' do
		protected! :admin

		status_effect = Entity::StatusType.find(params[:sid].to_i)
		row = params[:data]

		case params[:action]
			when 'create'
				arr = Effect::Base.save_state_from_datatable(status_effect, row)
				status_effect.impacts << arr
				status_effect.save
				res = Effect::Base.save_state_to_datatable(status_effect, arr)
				res[:index] = status_effect.impacts.length - 1
				return {row: res}.to_json
			when 'edit'
				index = params[:id].to_i
				arr = Effect::Base.save_state_from_datatable(status_effect, row)
				status_effect.impacts[index] = arr
				status_effect.save
				res = Effect::Base.save_state_to_datatable(status_effect, arr)
				res[:index] = index
				return {row: res}.to_json
			when 'remove'
				params[:id].each do |id|
					status_effect.impacts.delete_at id.to_i
				end
				status_effect.save
				return {}.to_json
		end

	end


	get '/admin/datasource/status_effect/:id/effects' do
			protected! :admin

			json = []

			status_effect = Entity::StatusType.find(params[:id].to_i)

			i = 0

			status_effect.impacts.each do |impact|
				res = Effect::Base.save_state_to_datatable(status_effect, impact)
				res[:index] = i
				json << res
				i += 1
			end

			return {data: json}.to_json

	end

	post '/admin/datatable/effect/define' do
		protected! :admin
		if params.has_key? :row
			use = params[:row]
			use[:type] = params[:values][:type] if params.has_key?(:values)
		else
			use = params[:values]
		end

		return Effect::Base.datatable_define(use).to_json
	end


	get '/admin/tile_type' do
		protected! :admin
		haml :'admin/tile_type', :layout => :'layouts/admin', :locals => {}
	end

	post '/admin/editor/tile_type' do
		protected! :admin
		row = params[:data]

		case params[:action]
			when 'create'
				res = Entity::TileType.new
				res.from_datatable row
				res.save
				return {row: res.to_datatable}.to_json
			when 'edit'
				res = Entity::TileType.find params[:id]
				res.from_datatable row
				res.save
				return {row: res.to_datatable}.to_json
		end
	end

	get '/admin/datasource/tile_type' do
		protected! :admin

		json = Array.new

		Entity::TileType.each do |type|
			json << type.to_datatable
		end

		return {data: json}.to_json
	end

	get '/admin/datasource/tile_type/:tile_id' do
		protected! :admin

		json = Array.new

		type = Entity::TileType.find(params[:tile_id].to_i)
		return {data: type.to_datatable}.to_json
	end

	get '/admin/item_types_by_id' do
		json = []
		Entity::ItemType.order_by(:name => 'asc').each do |type|
			json << {value: type.id, label: type.name}
		end
		return json.to_json
	end

	get '/admin/tile_type/:id/search_odds' do
		protected! :admin

		tile_type = Entity::TileType.find(params[:id].to_i)

		haml :'admin/tile_type_search_odds', :locals => {tile: tile_type}

	end

	post '/admin/editor/tile_type/:type_id/search_odds' do
		protected! :admin

		tile_type = Entity::TileType.find(params[:type_id].to_i)
		row = params[:data]

		case params[:action]
			when 'create'
				tile_type.search_table << [row[:id].to_i, row[:rate].to_i]
				tile_type.save
				res = {}
				res[:id] = row[:id]
				res[:index] = tile_type.search_table.length - 1
				res[:name] = Entity::ItemType.find(row[:id].to_i).name
				res[:rate] = row[:rate]
				return {row: res}.to_json
			when 'edit'
				tile_type.search_table[params[:id].to_i] = [row[:id].to_i, row[:rate].to_i]
				tile_type.save
				res = {}
				res[:id] = row[:id]
				res[:index] = params[:id]
				res[:name] = Entity::ItemType.find(row[:id].to_i).name
				res[:rate] = row[:rate]
				return {row: res}.to_json
			when 'remove'
				params[:id].each do |id|
					tile_type.search_table.delete_at id.to_i
				end
				tile_type.save
				return {}.to_json
		end
	end

	get '/admin/datasource/tile_type/:type_id/search_odds' do
		protected! :admin

		json = []

		tile = Entity::TileType.find(params[:type_id].to_i)

		i = 0

		tile.search_table.each do |result|
			res = {}
			item = Entity::ItemType.find(result[0])
			res[:rate] = result[1]
			res[:id] = item.id
			res[:index] = i
			res[:name] = item.name
			json << res
			i += 1
		end

		return {data: json}.to_json

	end


	get '/admin/item_type' do
		protected! :admin
		haml :'admin/item_type', :layout => :'layouts/admin', :locals => {}
	end

	get '/admin/datasource/item_type' do
		protected! :admin

		json = Array.new

		Entity::ItemType.each do |type|
			json << type.to_datatable
		end

		return {data: json}.to_json
	end

	get '/admin/datasource/item_type/:type_id' do
		protected! :admin

		type = Entity::ItemType.find(params[:type_id].to_i)

		return {data: type.to_datatable}.to_json
	end

	post '/admin/editor/item_type' do
		protected! :admin
		row = params[:data]

		case params[:action]
			when 'create'
				res = Entity::ItemType.new
				res.from_datatable row
				res.save
				return {row: res.to_datatable}.to_json
			when 'edit'
				res = Entity::ItemType.find params[:id]
				res.from_datatable row
				res.save
				return {row: res.to_datatable}.to_json
		end
	end

	get '/admin/statuses_by_id' do
		json = []
		Entity::StatusType.order_by(:name => 'asc').each do |type|
			json << {value: type.id, label: type.name}
		end
		return json.to_json
	end


	get '/admin/item_type/:id/statuses' do
		protected! :admin

		item_type = Entity::ItemType.find(params[:id].to_i)

		haml :'admin/item_type_sub', :locals => {type: item_type}

	end

	post '/admin/editor/item_type/:sid/statuses' do
		protected! :admin

		item_type = Entity::ItemType.find(params[:sid].to_i)
		row = params[:data]

		case params[:action]
			when 'create'
				item_type.statuses << row[:id]
				item_type.save
				res = {}
				res[:id] = row[:id]
				res[:index] = item_type.statuses.length - 1
				stats =  Entity::StatusType.find(row[:id].to_i)
				res[:name] = stats.name
				res[:description] = stats.describe '<br/>'
				return {row: res}.to_json
			when 'edit'
				item_type.statuses[params[:id].to_i] = row[:id]
				item_type.save
				res = {}
				res[:id] = row[:id]
				res[:index] = params[:id]
				stats =  Entity::StatusType.find(row[:id].to_i)
				res[:name] = stats.name
				res[:description] = stats.describe '<br/>'
				return {row: res}.to_json
			when 'remove'
				params[:id].each do |id|
					item_type.statuses.delete_at id.to_i
				end
				item_type.save
				return {}.to_json
		end

	end


	get '/admin/datasource/item_type/:id/statuses' do
		protected! :admin

		json = []

		item_type = Entity::ItemType.find(params[:id].to_i)

		i = 0

		item_type.statuses.each do |impact|
			res = {}
			state = Entity::StatusType.find(impact)
			res[:description] = state.describe '<br/>'
			res[:id] = state.id
			res[:name] = state.name
			res[:index] = i
			json << res
			i += 1
		end

		return {data: json}.to_json

	end







	get '/admin/tile_type/:id/statuses' do
		protected! :admin

		tile_type = Entity::TileType.find(params[:id].to_i)

		haml :'admin/tile_type_sub', :locals => {type: tile_type}

	end

	post '/admin/editor/tile_type/:sid/statuses' do
		protected! :admin

		tile_type = Entity::TileType.find(params[:sid].to_i)
		row = params[:data]

		case params[:action]
			when 'create'
				tile_type.statuses << row[:id]
				tile_type.save
				res = {}
				res[:id] = row[:id]
				res[:index] = tile_type.statuses.length - 1
				stats =  Entity::StatusType.find(row[:id].to_i)
				res[:name] = stats.name
				res[:description] = stats.describe '<br/>'
				return {row: res}.to_json
			when 'edit'
				tile_type.statuses[params[:id].to_i] = row[:id]
				tile_type.save
				res = {}
				res[:id] = row[:id]
				res[:index] = params[:id]
				stats =  Entity::StatusType.find(row[:id].to_i)
				res[:name] = stats.name
				res[:description] = stats.describe '<br/>'
				return {row: res}.to_json
			when 'remove'
				params[:id].each do |id|
					tile_type.statuses.delete_at id.to_i
				end
				tile_type.save
				return {}.to_json
		end

	end


	get '/admin/datasource/tile_type/:id/statuses' do
		protected! :admin

		json = []

		tile_type = Entity::TileType.find(params[:id].to_i)

		i = 0

		tile_type.statuses.each do |impact|
			res = {}
			state = Entity::StatusType.find(impact)
			res[:description] = state.describe '<br/>'
			res[:id] = state.id
			res[:name] = state.name
			res[:index] = i
			json << res
			i += 1
		end

		return {data: json}.to_json

	end




end