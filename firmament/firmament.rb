module Firmament

	class Plane

		attr_reader :plane
		attr_reader :dead_tile

		@@planes = ThreadSafe::Cache.new

		def initialize(plane)

			@plane = Entity::Plane.where({plane: plane.to_i}).first
			@@planes[plane.to_i] = self

			@dead_tile = VoidTile.new(@plane.id, VoidTile::DEAD_COORDINATE, VoidTile::DEAD_COORDINATE, VoidTile::DEAD_COORDINATE)

			@scheduler = Rufus::Scheduler.new

			@scheduler.cron '*/15 * * * *', :blocking => true do
				@characters.keys.each do |id|
					char = @characters[id]
					result = Entity::Status.tick char, :ap
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
				@characters.keys.each do |id|
					@characters[id].save
				end

			end

			@locations = ThreadSafe::Cache.new do |hashx, x|
				hashx[x.to_i] = ThreadSafe::Cache.new do |hashy, y|
					hashy[y.to_i] = ThreadSafe::Cache.new do |hashz, z|
						#puts "Loading tile ##{x},#{y},#{z}, #{@plane.plane}"

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

		def self.fetch(name)
			return @@planes.fetch(name.to_i, nil)
		end

		def self.loaded_ids
			@@planes.keys.clone
		end

		def remove_void(x, y ,z)
			@locations[x.to_i][y.to_i].delete(z.to_i) if @locations[x.to_i][y.to_i][z.to_i].instance_of?(VoidTile)
		end

		def save
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
			@characters.keys.each do |id|
				@characters[id].statuses.each do |status|
					status.unserialize
				end
				@characters[id].items.each do |item|
					item.statuses.each do |status|
						status.unserialize
					end
					item.type_statuses.each do |status|
						status.unserialize
					end
				end
			end
		end

	end
end