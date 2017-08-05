class Dash < Sinatra::Application

	# Allow use to ignore the fact that JTable and DataTables don't use the same verbs
	def self.get_or_post(url,&block)
		get(url,&block)
		post(url,&block)
	end

	# helper function to determine if we're using jtables
	def jtable?
		params[:jtable] == 'true' ? true : false
	end

	def table_output_helper(data)
		if jtable?
			{Result: :OK, Records: data}.to_json
		else
			{data: data}.to_json
		end
	end

	def table_row_output_helper(data)
		if jtable?
			{Result: :OK, Record: data}.to_json
		else
			{row: data}.to_json
		end
	end

	def table_delete_output_helper
		if jtable?
			{Result: :OK}.to_json
		else
			{}.to_json
		end
	end

	def table_options_format_helper(data)
		if jtable?
			json = []
			data.each do |option|
				json << {DisplayText: option[:label], Value: option[:value]}
			end
			{Result: :OK, Options: json}.to_json
		else
			data.to_json
		end
	end

	def fetch_row_from_params
		if jtable?
			params
		else
			params[:data]
		end
	end

	get '/admin/status_effect' do
		protected! :admin

		haml :'admin/status_effect', :layout => :'layouts/admin', :locals => {}
	end

	get_or_post '/admin/datasource/status_effect' do
		protected! :admin

		json = Array.new

		Entity::StatusType.each do |type|

			subjson = Array.new

			type.impacts.each do |impact|
				subjson << Effect::Base.unserialize(type, impact).describe
			end

			json << {id: type.id, name: type.name, family: type.family, impacts: subjson.join('<br/>')}
		end

		table_output_helper json
	end

	post '/admin/editor/status_type' do
		protected! :admin

		row = fetch_row_from_params

		case params[:action]
			when 'create'
				status = Entity::StatusType.new
				status.name = row[:name]
				status.family = row[:family].to_sym
				status.activation = row[:activation].to_sym
				status.save
				row[:id] = status.id
				row[:impacts] = status.describe '<br/>'
				return table_row_output_helper(row)
			when 'edit'
				status = Entity::StatusType.find params[:id]
				status.name = row[:name]
				status.family = row[:family].to_sym
				status.activation = row[:activation].to_sym
				status.save
				row[:id] = status.id
				row[:impacts] = status.describe '<br/>'
				return table_row_output_helper(row)
			when 'remove'
				return table_delete_output_helper
		end
	end

	get_or_post '/admin/datasource/status_effect/:status_id' do
		protected! :admin

		type = Entity::StatusType.find(params[:status_id].to_i)

		subjson = Array.new

		type.impacts.each do |impact|
			subjson << Effect::Base.unserialize(type, impact).describe
		end

		table_output_helper({id: type.id, name: type.name, family: type.family, impacts: subjson.join('<br/>')})
	end

	post '/admin/editor/status_effect/:sid/effects' do
		protected! :admin
		row = fetch_row_from_params

		status_effect = Entity::StatusType.find(params[:sid].to_i)

		case params[:action]
			when 'create'
				arr = Effect::Base.save_state_from_datatable(status_effect, row)
				status_effect.impacts << arr
				status_effect.save
				res = Effect::Base.save_state_to_datatable(status_effect, arr)
				res[:index] = status_effect.impacts.length - 1
				return table_row_output_helper(res)
			when 'edit'
				index = params[:id].to_i
				arr = Effect::Base.save_state_from_datatable(status_effect, row)
				status_effect.impacts[index] = arr
				status_effect.save
				res = Effect::Base.save_state_to_datatable(status_effect, arr)
				res[:index] = index
				return table_row_output_helper(res)
			when 'remove'
				params[:id].each do |id|
					status_effect.impacts.delete_at id.to_i
				end
				status_effect.save
				return table_delete_output_helper
		end

	end


	get_or_post '/admin/datasource/status_effect/:id/effects' do
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

			table_output_helper json
	end

	get_or_post '/admin/datatable/effect/define' do
		protected! :admin
		if jtable?
			use = {type: params[:type]}
		else
			if params.has_key? :row
				use = params[:row]
				use[:type] = params[:values][:type] if params.has_key?(:values)
			else
				use = params[:values]
			end
		end
		return Effect::Base.datatable_define(use).to_json
	end


	get '/admin/tile_type' do
		protected! :admin
		haml :'admin/tile_type', :layout => :'layouts/admin', :locals => {}
	end

	post '/admin/editor/tile_type' do
		protected! :admin
		row = fetch_row_from_params

		case params[:action]
			when 'create'
				res = Entity::TileType.new
				res.from_datatable row
				res.save
				return table_row_output_helper(res.to_datatable)
			when 'edit'
				res = Entity::TileType.find params[:id]
				res.from_datatable row
				res.save
				return table_row_output_helper(res.to_datatable)
		end
	end

	get_or_post '/admin/datasource/tile_type' do
		protected! :admin

		json = Array.new

		Entity::TileType.each do |type|
			json << type.to_datatable
		end

		table_output_helper json
	end

	get_or_post '/admin/datasource/tile_type/:tile_id' do
		protected! :admin


		type = Entity::TileType.find(params[:tile_id].to_i)

		table_output_helper(type.to_datatable)
	end

	get_or_post '/admin/item_types_by_id' do
		json = []
		Entity::ItemType.order_by(:name => 'asc').each do |type|
			json << {value: type.id, label: type.name}
		end
		table_options_format_helper json
	end

	get_or_post '/admin/editor/tile_type/:type_id/search_odds' do
		protected! :admin
		row = fetch_row_from_params
		tile_type = Entity::TileType.find(params[:type_id].to_i)

		case params[:action]
			when 'create'
				tile_type.search_table << [row[:id].to_i, row[:rate].to_i]
				tile_type.save
				res = {}
				res[:id] = row[:id]
				res[:index] = tile_type.search_table.length - 1
				res[:name] = Entity::ItemType.find(row[:id].to_i).name
				res[:rate] = row[:rate]
				return table_row_output_helper(res)
			when 'edit'
				tile_type.search_table[params[:id].to_i] = [row[:id].to_i, row[:rate].to_i]
				tile_type.save
				res = {}
				res[:id] = row[:id]
				res[:index] = params[:id]
				res[:name] = Entity::ItemType.find(row[:id].to_i).name
				res[:rate] = row[:rate]
				return table_row_output_helper(res)
			when 'remove'
				params[:id].each do |id|
					tile_type.search_table.delete_at id.to_i
				end
				tile_type.save
				return table_delete_output_helper
		end
	end

	get_or_post '/admin/datasource/tile_type/:type_id/search_odds' do
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

		table_output_helper json

	end


	get '/admin/item_type' do
		protected! :admin
		haml :'admin/item_type', :layout => :'layouts/admin', :locals => {}
	end

	get_or_post '/admin/datasource/item_type' do
		protected! :admin

		json = Array.new

		Entity::ItemType.each do |type|
			json << type.to_datatable
		end

		table_output_helper json
	end

	get_or_post '/admin/datasource/item_type/:type_id' do
		protected! :admin

		type = Entity::ItemType.find(params[:type_id].to_i)

		table_output_helper type.to_datatable
	end

	post '/admin/editor/item_type' do
		protected! :admin
		row = fetch_row_from_params

		case params[:action]
			when 'create'
				res = Entity::ItemType.new
				res.from_datatable row
				res.save
				return table_row_output_helper(res.to_datatable)
			when 'edit'
				res = Entity::ItemType.find params[:id]
				res.from_datatable row
				res.save
				return table_row_output_helper(res.to_datatable)
		end
	end

	get_or_post'/admin/statuses_by_id' do
		json = []
		Entity::StatusType.order_by(:name => 'asc').each do |type|
			json << {value: type.id, label: type.name}
		end
		table_options_format_helper json
	end

	post '/admin/editor/item_type/:sid/statuses' do
		protected! :admin
		row = fetch_row_from_params

		item_type = Entity::ItemType.find(params[:sid].to_i)

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
				return table_row_output_helper(res)
			when 'edit'
				item_type.statuses[params[:id].to_i] = row[:id]
				item_type.save
				res = {}
				res[:id] = row[:id]
				res[:index] = params[:id]
				stats =  Entity::StatusType.find(row[:id].to_i)
				res[:name] = stats.name
				res[:description] = stats.describe '<br/>'
				return table_row_output_helper(res)
			when 'remove'
				if jtable?
					item_type.statuses.delete_at params[:index].to_i
				else
					params[:id].each do |id|
						item_type.statuses.delete_at id.to_i
					end
				end
				item_type.save
				return table_delete_output_helper
		end

	end


	get_or_post '/admin/datasource/item_type/:id/statuses' do
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

		table_output_helper json

	end


	get_or_post '/admin/editor/tile_type/:sid/statuses' do
		protected! :admin
		row = fetch_row_from_params

		tile_type = Entity::TileType.find(params[:sid].to_i)

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
				return table_row_output_helper(res)
			when 'edit'
				tile_type.statuses[params[:id].to_i] = row[:id]
				tile_type.save
				res = {}
				res[:id] = row[:id]
				res[:index] = params[:id]
				stats =  Entity::StatusType.find(row[:id].to_i)
				res[:name] = stats.name
				res[:description] = stats.describe '<br/>'
				return table_row_output_helper(res)
			when 'remove'
				params[:id].each do |id|
					tile_type.statuses.delete_at id.to_i
				end
				tile_type.save
				return table_delete_output_helper
		end

	end


	get_or_post '/admin/datasource/tile_type/:id/statuses' do
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

		table_output_helper json

	end




end