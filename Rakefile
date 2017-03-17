desc 'Resets the database to its initial seeded state'
task :bounce => [:wipe, :seed, :fixtures]

desc 'Starts an irb session with the environment loaded'
task :console => :environment do
	require 'irb'
	ARGV.clear
	IRB.start
end
task :default => :console

task :environment do
	puts 'Setting up environment... '
	require 'bundler'
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

desc 'Serves the app in dev mode'
task :serve do
	`./app.rb`
end

desc 'Puts initial data in the db '
task :seed => :environment do
	buildDataFromFolder("seeds")
end

desc 'Put development accounts in the db'
task :fixtures => :environment do
	buildDataFromFolder("fixtures")
end

desc 'Deletes all the things from the db'
task :wipe => :environment do
	Entity.constants.select{|c| Entity.const_get(c).is_a? Class}.each do |klass_sym|
		klass = Entity.class_eval(klass_sym.to_s)
		next unless klass.respond_to?(:destroy_all)
		puts "Wiping #{klass_sym}... "
		count = klass.destroy_all
		puts " Done. (removed #{count} records)"
	end
	puts
end

def buildDataFromFolder(folder)
	belongAccount = nil
	Dir[Dir.pwd+"/" + folder + "/*.json"].sort.each do |seed_file|
		next unless File.file? seed_file
		trimmedFileName = File.basename(seed_file, '.json').split(" ")
        klass = trimmedFileName[1].classify
		puts "Seeding #{klass}... "
		(seeds = JSON.parse(File.read(seed_file))).each do |seed|
			entity = Entity.class_eval(klass).new
			seed.each_key do |property|
				entity.send "#{property}=", seed[property]
			end
			if folder == "fixtures"
				if trimmedFileName[0].to_i == 1
					belongAccount = entity
				end
				if trimmedFileName[0].to_i == 2
					entity.account_id = belongAccount.id
				end
			end
			entity.save
		end
		puts " Done. (seeded #{seeds.count} records)"
	end
	puts
end
