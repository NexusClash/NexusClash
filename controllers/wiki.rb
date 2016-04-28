class Dash < Sinatra::Application
	get '/wiki/:page' do
			redirect to("http://nexusclash.windrunner.mx/wiki/index.php?title=#{params[:page].gsub(' ', '_')}")
	end
end