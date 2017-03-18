class Dash < Sinatra::Application
	get '/wiki/:page' do
			redirect to("http://nexusclash.windrunner.mx/wiki/index.php?title=#{params[:page].gsub(' ', '_')}")
	end

	get '/autowiki/location/:tile_type_id/:name' do
		location = Entity::TileType.find(params[:tile_type_id])
		rnd_max = location.search_table.inject(0) { |sum, itm| sum + itm[1] }
		haml :'autowiki/location', :layout => @layout, :locals => {:location => location, :search_rate_total => rnd_max}
	end

	get '/autowiki/tile/:x/:y/:z' do
		tile = Entity::Tile.find_by(x: params[:x], y: params[:y], z: params[:z], plane: Instance.plane)
		redirect to ("/autowiki/location/#{tile.type.id}/#{tile.type.name}")
	end
end
