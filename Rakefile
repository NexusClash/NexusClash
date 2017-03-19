require 'bundler'

Dir.glob('tasks/*.rake').each { |r| import r }

begin
	Bundler.setup(:default, :development)
rescue Bunder::BundlerError => e
	$stderr.puts e.message
	$stderr.puts "Run `bundle install` to install missing gems"
	exit e.status_code
end

desc 'Starts an irb session with the environment loaded'
task :console => :environment do
	require 'irb'
	ARGV.clear
	IRB.start
end
task :default => :console

task :environment do
	puts 'Setting up environment... '

	Bundler.require
    #require 'pry'
	Mongoid.load!('mongoid.yml')
	require_rel 'enums'
	require_rel 'config'
	require_rel 'behaviour/core'
	require_rel 'behaviour/intent/generic'
	require_rel 'behaviour/intent'
	require_rel 'behaviour/effect/generic'
	require_rel 'behaviour/effect'
	require_rel 'mixins'
	require_rel 'models'
	require_rel 'firmament/entities'
	require_rel 'firmament'
	puts 'Done.'
	puts
end

desc "Kills every character"
task :kill_them_all => :environment do
	Firmament::Plane.new Instance.plane
	Entity::Character.all.each do |character|
		character.kill!
		character.x = VoidTile::DEAD_COORDINATE
		character.y = VoidTile::DEAD_COORDINATE
		character.z = VoidTile::DEAD_COORDINATE
		character.save
	end
end

desc 'Serves the app in dev mode'
task :serve do
	`./app.rb`
end
