task :environment do
	puts 'Setting up environment... '
	require 'bundler'
	Bundler.require
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


desc 'Puts initial data in the db '
task :seed => :environment do
	Dir[Dir.pwd+"/seeds/*.json"].each do |seed_file|
		next unless File.file? seed_file
		klass = File.basename(seed_file, '.json').classify
		puts "Seeding #{klass}... "
		(seeds = JSON.parse(File.read(seed_file))).each do |seed|
			entity = Entity.class_eval(klass).new
			seed.each_key do |property|
				entity.send "#{property}=", seed[property]
			end
			entity.save
		end
		puts " Done. (seeded #{seeds.count} records)"
	end
	puts
end

desc 'Deletes all the things from the db'
task :wipe => :environment do
	Entity.constants.select{|c| Entity.const_get(c).is_a? Class}.each do |klass_sym|
		puts "Wiping #{klass_sym}... "
		count = Entity.class_eval(klass_sym.to_s).destroy_all
		puts " Done. (removed #{count} records)"
	end
	puts
end

desc 'Resets the database to its initial seeded state'
task :bounce => [:wipe, :seed]

desc 'Starts an irb session with the environment loaded'
task :console => :environment do
	require 'irb'
	ARGV.clear
	IRB.start
end
task :default => :console

