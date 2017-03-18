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

    desc 'Build seed files from database'
    task :build_seed => :environment do
      write_seed(Entity::StatusType, 'status_type', 1)
      write_seed(Entity::Plane, 'plane', 2)
      write_seed(Entity::TileType, 'tile_type', 3)
      write_seed(Entity::Tile, 'tile', 4)
      write_seed(Entity::ItemType, 'item_type', 5)
    end
  end
end

def buildDataFromFolder(folder)
	belongAccount = nil
	Dir[Dir.pwd+"/" + folder + "/*.json"].sort.each do |seed_file|
		next unless File.file? seed_file
		trimmedFileName = File.basename(seed_file, '.json').split("-")
    klass = trimmedFileName[1].classify
		puts "Seeding #{klass}... "
		(seeds = JSON.parse(File.read(seed_file))).each do |seed|
			entity = Entity.class_eval(klass).new

      keys = seed.keys
      id_keys = keys.select { |key| key.end_with? 'id' }
      other_keys = keys - id_keys

      keys = id_keys + other_keys

			keys.each do |property|
				entity.send "#{property}=", seed[property] unless property == '_id'
			end
      entity.plane = Instance.plane if entity.respond_to? 'plane='
			entity.save
		end
		puts " Done. (seeded #{seeds.count} records)"
	end
	puts
end

def write_seed(collection, filename, filenumber)
  items = build_json_array(collection)
  write_json_file(items, filename, filenumber)

  puts "Build #{filename} file with #{items.count} records"
end

def write_json_file(items, filename, filenumber)
  path = Dir.pwd + '/seeds/' + filenumber.to_s + '-' + filename + '.json'

  FileUtils.rm(path) if File.exist?(path)

  File.open(path, 'w+') do |file|
    file.puts('[')

    if items.any?
      items.take(items.count - 1).each {|item| file.puts(item + ',')}
      file.puts(items.last)
    end

    file.puts(']')
  end
end

def build_json_array(collection)
  json_array = []

  collection.all.each do |item|
    json = item.to_json
    object = JSON.parse(json)
    json_array << object.except('_id').to_json
  end

  json_array
end
