class Dash < Sinatra::Application
	get '/wiki/:page' do
			redirect to("http://nexusclash.windrunner.mx/wiki/index.php?title=#{params[:page].gsub(' ', '_')}")
	end

	get '/autowiki/location/:tile_type_id/:name' do
		location = Entity::TileType.find_by({tile_type_id: params[:tile_type_id]})
		rnd_max = location.search_table.inject(0) { |sum, itm| sum + itm[1] }
		haml :'autowiki/location', :layout => @layout, :locals => {:location => location, :search_rate_total => rnd_max}
	end

	get '/autowiki/tile/:x/:y/:z' do
		game = Firmament::Plane.fetch Instance.plane
		tile = game.map params[:x], params[:y], params[:z]
		redirect to ("/autowiki/location/#{tile.type.id}/#{tile.type.name}")
	end
end
