unless ENV['RACK_ENV'] == 'production'
  namespace :db do
    desc 'Load seed data into the database'
    task :seed => :environment do
      buildDataFromFolder("seeds")
    end

    desc 'Load account data into the database'
    task :fixtures => :environment do
      buildDataFromFolder("fixtures")

      # Harrison Heights has too much void.
      Rake::Task["kill_them_all"].invoke if Instance.plane == 3
    end
  end
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
      entity.plane = Instance.plane if entity.respond_to? 'plane='
			entity.save
		end
		puts " Done. (seeded #{seeds.count} records)"
	end
	puts
end
