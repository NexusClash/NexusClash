if defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby'
	(require 'java'
	import java.lang.management.ManagementFactory
	)
end


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

	get '/admin/map' do
		protected! :admin

		haml :'admin/map', :layout => :'layouts/admin', :locals => {}

	end

	get '/admin/memory' do
		if defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby'
			mem_bean = ManagementFactory.memory_mx_bean
			mem_bean.verbose = true
			heap = mem_bean.heap_memory_usage.to_s.split
			heap_used = heap[5].split('(')[0]
			heap_max = heap[11].split('(')[0]
			non_heap = mem_bean.non_heap_memory_usage.to_s.split
			non_heap_used = non_heap[5].split('(')[0]
			non_heap_max = non_heap[11].split('(')[0]
		else
			heap_used = -1
			heap_max = -1
			non_heap_used = -1
			non_heap_max = -1
		end
		haml :'admin/memory', :layout => :'layouts/empty', :locals => {heap_used: heap_used, heap_max: heap_max, non_heap_used: non_heap_used, non_heap_max: non_heap_max}
	end


	get '/admin/preload_alpha' do
		protected! :admin

		p = Entity::Plane.new
		p.name = 'Alphaville'
		p.domain = 'alpha.nexuscla.sh'
		p.save

		Entity::Character.update_all({x: VoidTile::DEAD_COORDINATE, y: VoidTile::DEAD_COORDINATE, z: VoidTile::DEAD_COORDINATE, hp: 0, plane: 3})

		Entity::Tile.delete



		alpha = [[11, 14, 1, 1, 'The Ammo Shack', 'Gun Store', '', '', 1, 1, 0, 0, 1, 0, 0, 0, 30, 'Harriston Heights', 1, 0, 746, 'Redcliffe Power', 464, 'Gun Store', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		             [12, 10, 1, 1, 'Sarah\'s Sundries', 'Corner Store', '', '', 1, 1, 0, 0, 0, 0, 0, 1, 30, 'Harriston Heights', 1, 1, 890, 'Redcliffe Power', 505, 'Corner Store', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		             [12, 11, 1, 1, 'Pump and Run', 'Gas Station', '', '', 1, 1, 0, 0, 0, 0, 0, 1, 30, 'Harriston Heights', 1, 0, 746, 'Redcliffe Power', 506, 'Gas Station', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		             [12, 12, 1, 1, 'The Kitty Twister', 'Nightclub', '', '', 1, 2, 0, 0, 0, 0, 0, 1, 30, 'Harriston Heights', 1, 0, 746, 'Redcliffe Power', 507, 'Nightclub', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		             [12, 13, 1, 1, 'House', 'House', '', '', 1, 1, 0, 0, 0, 0, 0, 1, 30, 'Harriston Heights', 1, 0, 149, 'Redcliffe Power', 508, 'House', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		             [12, 14, 1, 1, 'Slum', 'Slum', '', '', 1, 2, 0, 0, 0, 0, 0, 1, 30, 'Harriston Heights', 1, 0, 746, 'Redcliffe Power', 509, 'Slum', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		             [12, 15, 1, 1, 'House', 'House', '', '', 1, 1, 0, 0, 0, 0, 0, 1, 30, 'Harriston Heights', 1, 0, 746, 'Redcliffe Power', 510, 'House', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		             [13, 10, 1, 1, 'The Red Room', 'Nightclub', '', '', 1, 1, 0, 0, 0, 0, 0, 1, 30, 'Harriston Heights', 1, 1, 890, 'Redcliffe Power', 550, 'Nightclub', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		             [13, 11, 1, 1, 'Pressacre Paper Mill', 'Factory', '', '', 1, 1, 0, 0, 0, 0, 1, 0, 30, 'Harriston Heights', 1, 1, 831, 'Redcliffe Power', 551, 'Factory', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		             [13, 12, 1, 1, 'Slum', 'Slum', '', '', 1, 1, 0, 0, 0, 0, 0, 1, 30, 'Harriston Heights', 1, 0, 149, 'Redcliffe Power', 552, 'Slum', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		             [13, 13, 1, 1, 'Slum', 'Slum', '', '', 1, 1, 0, 0, 0, 0, 0, 1, 30, 'Harriston Heights', 1, 0, 746, 'Redcliffe Power', 553, 'Slum', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		             [13, 14, 1, 1, 'Viking Foods', 'Supermarket', '', '', 1, 0, 0, 0, 0, 0, 0, 1, 0, 'Harriston Heights', 1, 1, 661, 'Redcliffe Power', 554, 'Supermarket', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		             [13, 15, 1, 1, 'Harriston First Fire', 'Fire Station', '', '', 1, 1, 0, 0, 0, 0, 0, 0, 30, 'Harriston Heights', 1, 0, 746, 'Redcliffe Power', 555, 'Fire Station', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		             [14, 10, 1, 1, 'House', 'House', '', '', 1, 0, 0, 0, 0, 0, 0, 1, 0, 'Harriston Heights', 1, 1, 264, 'Redcliffe Power', 595, 'House', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		             [14, 11, 1, 1, 'Captain Clucky\'s Chicken and Waffles', 'Restaurant', '', '', 1, 1, 0, 0, 0, 0, 0, 1, 30, 'Harriston Heights', 1, 1, 661, 'Redcliffe Power', 596, 'Restaurant', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		             [14, 12, 1, 1, 'Food N More', 'Supermarket', '', '', 1, 1, 0, 0, 0, 0, 0, 1, 30, 'Harriston Heights', 1, 0, 746, 'Redcliffe Power', 597, 'Supermarket', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		             [14, 13, 1, 1, 'Harris Elementary School', 'School', '', '', 1, 1, 0, 0, 0, 0, 0, 1, 30, 'Harriston Heights', 1, 1, 800, 'Redcliffe Power', 598, 'School', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		             [14, 14, 1, 1, 'St. Thomas Cathedral', 'Church', '', '', 1, 1, 0, 0, 0, 0, 0, 0, 30, 'Harriston Heights', 1, 0, 746, 'Redcliffe Power', 599, 'Church', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		             [14, 15, 1, 1, 'Dan\'s Liquor', 'Corner Store', '', '', 1, 2, 0, 0, 0, 0, 0, 1, 30, 'Harriston Heights', 1, 1, 800, 'Redcliffe Power', 600, 'Corner Store', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		             [15, 9, 1, 1, 'Apartment Building', 'Apartment Building', '', '', 1, 1, 0, 0, 0, 0, 0, 1, 30, 'Harriston Heights', 1, 1, 264, 'Redcliffe Power', 639, 'Apartment Building', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		             [15, 10, 1, 1, 'Apartment Building', 'Apartment Building', '', '', 1, 1, 0, 0, 0, 0, 0, 1, 30, 'Harriston Heights', 1, 1, 6, 'Redcliffe Power', 640, 'Apartment Building', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		             [15, 11, 1, 1, 'House', 'House', '', '', 1, 2, 0, 0, 0, 0, 0, 1, 15, 'Harriston Heights', 1, 0, 746, 'Redcliffe Power', 641, 'House', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		             [16, 10, 1, 1, 'Warehouse', 'Warehouse', '', '', 1, 1, 0, 0, 0, 0, 0, 1, 30, 'Harriston Heights', 1, 0, 746, 'Redcliffe Power', 685, 'Warehouse', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		             [16, 11, 1, 1, 'Plugs and Slugs', 'Gun Store', '', '', 1, 1, 0, 0, 1, 0, 0, 0, 30, 'Harriston Heights', 1, 1, 264, 'Redcliffe Power', 686, 'Gun Store', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		             [17, 10, 1, 1, 'The Shops at the Heights', 'Mall', '', '', 1, 1, 0, 0, 0, 0, 0, 0, 30, 'Harriston Heights', 1, 1, 711, 'Redcliffe Power', 730, 'Mall', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', '']]


		alpha.each do |row|


			#exterior
			tile = Entity::Tile.new
			type = Entity::TileType.where(name: row[4]).first
			tile.type = type
			tile.name = row[3]
			tile.x = row[0]
			tile.y = row[1]
			tile.description = row[5]
			tile.z = 0
			tile.plane = 3
			tile.save
			#interior
			if row[2] == 1
				tile = Entity::Tile.new
				type = Entity::TileType.where(name: row[4] + ' (Inside)').first
				tile.type = type
				tile.name = row[3]
				tile.x = row[0]
				tile.y = row[1]
				tile.description = row[6]
				tile.z = 1
				tile.plane = 3
				tile.save
			end
		end
	end


end