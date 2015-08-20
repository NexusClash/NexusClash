class Dash < Sinatra::Application
	get '/admin' do
		protected! :admin

		haml :'admin/index', :layout => :'layouts/admin', :locals => {}
	end

	get '/admin/save' do
		protected! :admin

		Firmament::Plane.loaded_ids.each do |id|

			plane = Firmament::Plane.fetch id
			plane.save

		end

		redirect to('/admin')
	end

	get '/admin/sync' do
		protected! :admin

		Firmament::Plane.loaded_ids.each do |id|

			plane = Firmament::Plane.fetch id
			plane.sync

		end

		redirect to('/admin')
	end

end