module Firmament

	class Plane

		attr_reader :id
		attr_reader :plane
		attr_reader :dead_tile
		@@planes = ThreadSafe::Cache.new
		@@admins = ThreadSafe::Array.new
		@@servers = ThreadSafe::Cache.new

		def self.admins
			@@admins
		end

		def self.add_admin(admin)
			@@admins << admin
		end

		def self.remove_admin(admin)
			@@admins.delete(admin)
		end

		def self.servers
			@@servers
		end

		def self.server(server)
			return @@servers.fetch(server.to_i, nil)
		end

		def self.add_server(server)
			@@servers[server.plane] = server
		end

		def self.remove_server(plane)
			@@servers.delete(plane)
		end

		attr_reader :pending_deletion, :pending_save

		def initialize(plane)
			@pending_deletion = Queue.new
			@pending_save = Queue.new

			@id = plane.to_i
			@plane = Entity::Plane.where({plane: plane.to_i}).first || Entity::Plane.new
			@@planes[plane.to_i] = self

			@dead_tile = VoidTile.new(@plane.id, VoidTile::DEAD_COORDINATE, VoidTile::DEAD_COORDINATE, VoidTile::DEAD_COORDINATE)

			ENV['TZ'] = 'Europe/London'
			@scheduler = Rufus::Scheduler.new

			@scheduler.cron '*/15 * * * *', :blocking => true do
				@characters.keys.each do |id|
					char = @characters[id]
					result = Entity::Status.tick char, :ap
					result2 = Entity::Status.tick char, :status
					result = result2 if result < result2
					char.broadcast_self result
				end
			end

			@scheduler.cron '* * * * *', :blocking => true do
				@characters.keys.each do |id|
					char = @characters[id]
					result = Entity::Status.tick char, :minute
					char.broadcast_self result
				end
			end

			@scheduler.every '15m', :blocking => true do
				save
			end

			@locations = ThreadSafe::Cache.new do |hashx, x|
				hashx[x.to_i] = ThreadSafe::Cache.new do |hashy, y|
					hashy[y.to_i] = ThreadSafe::Cache.new do |hashz, z|
						puts "Loading tile ##{x},#{y},#{z}, #{@plane.plane}"

						newtile = VoidTile.new(@plane.plane.to_i, x.to_i, y.to_i, z.to_i)

						if Entity::Tile.where({plane: @plane.plane.to_i, x: x.to_i, y: y.to_i, z:z.to_i}).exists? then
							newtile = Entity::Tile.find_by({plane: @plane.plane.to_i, x: x.to_i, y: y.to_i, z:z.to_i})
							newtile.characters = ThreadSafe::Array.new
						else
							newtile = VoidTile.new @plane.plane.to_i, x.to_i, y.to_i, z.to_i
						end

						hashz[z.to_i] = newtile

						Entity::Character.where({plane: @plane.plane.to_i, x: x.to_i, y: y.to_i, z:z.to_i}).each do |char|
							if self.character? char.id.to_i
								newtile.characters << @characters[char.id.to_i]
							else
								char.location = newtile
								@characters[char.id.to_i] = char
								newtile.characters << char
							end
						end

						newtile
					end
				end
			end

			@characters = ThreadSafe::Cache.new do |hash, char_id|
				newchar = Entity::Character.find(char_id)
				hash[newchar.id.to_i] = newchar
				newchar.location = @locations[newchar.x.to_i][newchar.y.to_i][newchar.z.to_i]
				#newchar.location.characters << newchar
				newchar
			end

			@locations[VoidTile::DEAD_COORDINATE][VoidTile::DEAD_COORDINATE][VoidTile::DEAD_COORDINATE] = @dead_tile

			# Preload all map tiles and all characters

			puts 'Loading Map...'

			Entity::Tile.where({plane: @plane.plane.to_i}).each do |tile|
				@locations[tile.x][tile.y][tile.z] = tile
			end

			puts 'Loading Characters...'

			Entity::Character.where({plane: @plane.plane.to_i}).each do |newchar|
				newchar.statuses << Entity::Status.source_from(1) if newchar.statuses.count == 0
				newchar.location = @locations[newchar.x][newchar.y][newchar.z]
				@locations[newchar.x][newchar.y][newchar.z].characters << newchar
				@characters[newchar.id] = newchar
			end


		end

		def map(x, y, z)
			@locations[x.to_i][y.to_i][z.to_i]
		end

		def map?(x, y, z)
			!@locations[x.to_i][y.to_i][z.to_i].instance_of?(VoidTile)
		end

		def character(id)
			@characters[id.to_i]
		end

		def character?(id)
			@characters.key? id.to_i
		end

		def unload_character!(id)
			id = id.to_i
			if character? id
				char = character id
				char.location.characters.delete(char)
				@characters.delete(id)
			end
		end

		def is_day?
			0 == Time.now.hour % 2
		end

		def self.fetch(name)
			return @@planes.fetch(name.to_i, nil)
		end

		def self.loaded_ids
			@@planes.keys.clone
		end

		def remove_void(x, y ,z)
			x = x.to_i
			y = y.to_i
			z = z.to_i

			if Entity::Tile.where({plane: @plane.plane.to_i, x: x, y: y, z:z}).exists? then
				newtile = Entity::Tile.find_by({plane: @plane.plane.to_i, x: x, y: y, z:z})
				newtile.characters = ThreadSafe::Array.new

				@locations[x][y][z] = newtile

				Entity::Character.where({plane: @plane.plane.to_i, x: x.to_i, y: y.to_i, z:z.to_i}).each do |char|
					if self.character? char.id.to_i
						newtile.characters << @characters[char.id.to_i]
					else
						char.location = newtile
						@characters[char.id.to_i] = char
						newtile.characters << char
					end
				end
			else
				@locations[x][y][z] = VoidTile.new @plane.plane.to_i, x.to_i, y.to_i, z.to_i
			end
		end

		def save
			until @pending_deletion.empty? do
				@pending_deletion.pop.delete
			end
			until @pending_save.empty? do
				@pending_save.pop.save
			end
			@characters.keys.each do |id|
				@characters[id].save
			end
			@locations.keys.each do |x|
				locx = @locations[x]
				locx.keys.each do |y|
					locy = locx[y]
					locy.keys.each do |z|
						locy[z].save
					end
				end
			end
		end

		def sync
			Entity::TileType.reload_types
			Entity::ItemType.reload_types
			Entity::StatusType.purge_cache
			Entity::StatusType.load_types
			@characters.keys.each do |id|
				char = @characters[id]
				char.transient_tags.clear
				char.weight_max = 50
				char.hp_max_mod = 0
				char.statuses.each do |status|
					status.unserialize
				end
				char.items.each do |item|
					item.statuses.each do |status|
						status.unserialize
					end
					item.type_statuses.each do |status|
						status.unserialize
					end
				end
			end
			@locations.keys.each do |x|
				@locations[x].keys.each do |y|
					@locations[x][y].keys.each do |z|
						@locations[x][y][z].unserialise_statuses
					end
				end
			end
		end
	end
end
