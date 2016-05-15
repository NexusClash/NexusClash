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

		alpha = [[9, 11, 1, 1, 'House', 'House', '', '', 1, 1, 0, 0, 0, 0, 0, 1, 30, 'Upper Harriston Heights', 1, 1, 149, 'Redcliffe Power', 371, 'House', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		         [9, 14, 1, 1, 'Slum', 'Slum', '', '', 1, 0, 0, 0, 0, 0, 0, 1, 0, 'Upper Harriston Heights', 1, 0, 746, 'Redcliffe Power', 374, 'Slum', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		         [10, 8, 1, 1, 'Hot Corner', 'Bar', '', '', 1, 0, 0, 0, 0, 0, 0, 1, 0, 'Upper Harriston Heights', 1, 1, 264, 'Redcliffe Power', 413, 'Bar', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		         [10, 9, 1, 1, 'Apartment Building', 'Apartment Building', '', '', 1, 1, 0, 0, 0, 0, 0, 1, 15, 'Upper Harriston Heights', 1, 1, 661, 'Redcliffe Power', 414, 'Apartment Building', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		         [10, 10, 1, 1, 'Slum', 'Slum', '', '', 1, 1, 0, 0, 0, 0, 0, 1, 30, 'Upper Harriston Heights', 1, 0, 746, 'Redcliffe Power', 415, 'Slum', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		         [10, 11, 1, 1, 'House', 'House', '', '', 1, 1, 0, 0, 0, 0, 0, 1, 30, 'Upper Harriston Heights', 1, 1, 149, 'Redcliffe Power', 416, 'House', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		         [10, 13, 1, 1, 'Second Memorial Hospital', 'Hospital', '', '', 1, 1, 0, 0, 0, 0, 0, 0, 30, 'Upper Harriston Heights', 1, 0, 746, 'Redcliffe Power', 418, 'Hospital', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		         [10, 14, 1, 1, 'The Greasy Spoon', 'Restaurant', '', '', 1, 1, 0, 0, 0, 0, 0, 1, 30, 'Upper Harriston Heights', 1, 0, 746, 'Redcliffe Power', 419, 'Restaurant', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		         [11, 9, 1, 0, 'Junkyard', 'Junkyard', '', '', 1, 1, 0, 0, 0, 0, 0, 0, 20, 'Upper Harriston Heights', 1, 1, 0, '', 459, 'Junkyard', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		         [11, 10, 1, 0, 'Westfield Park', 'Park', '', '', 1, 1, 0, 0, 0, 0, 0, 0, 20, 'Upper Harriston Heights', 1, 1, 0, '', 460, 'Park', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		         [11, 11, 1, 1, 'Warehouse', 'Warehouse', '', '', 1, 1, 0, 0, 0, 0, 0, 1, 30, 'Upper Harriston Heights', 1, 0, 746, 'Redcliffe Power', 461, 'Warehouse', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		         [11, 12, 1, 1, 'Third Bank Tower', 'Office Building', '', '', 1, 1, 0, 0, 0, 0, 0, 1, 30, 'Upper Harriston Heights', 1, 0, 746, 'Redcliffe Power', 462, 'Office Building', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		         [11, 13, 1, 1, 'Apartment Building', 'Apartment Building', '', '', 1, 1, 0, 0, 0, 0, 0, 1, 30, 'Upper Harriston Heights', 1, 0, 746, 'Redcliffe Power', 463, 'Apartment Building', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		         [12, 9, 1, 1, 'House', 'House', '', '', 1, 1, 0, 0, 0, 0, 0, 1, 30, 'Upper Harriston Heights', 1, 0, 746, 'Redcliffe Power', 504, 'House', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		         [13, 8, 1, 1, 'Slum', 'Slum', '', '', 1, 1, 0, 0, 0, 0, 0, 1, 30, 'Upper Harriston Heights', 1, 1, 850, 'Redcliffe Power', 548, 'Slum', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		         [13, 9, 1, 1, 'Harriston Heights Police Department', 'Police Station', '', '', 1, 1, 0, 0, 0, 0, 0, 0, 30, 'Upper Harriston Heights', 1, 1, 890, 'Redcliffe Power', 549, 'Police Station', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		         [14, 16, 1, 1, 'Museum of Natural History', 'Museum', '', '', 1, 1, 0, 0, 0, 0, 0, 0, 30, 'Lower Harriston Heights', 1, 1, 149, 'Redcliffe Power', 601, 'Museum', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		         [15, 12, 1, 1, 'Griffonshead Brewery', 'Bar', '', '', 1, 1, 0, 0, 0, 0, 0, 1, 30, 'Lower Harriston Heights', 1, 1, 758, 'Redcliffe Power', 642, 'Bar', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		         [15, 13, 1, 1, 'Apartment Building', 'Apartment Building', '', '', 1, 1, 0, 0, 0, 0, 0, 1, 30, 'Lower Harriston Heights', 1, 1, 890, 'Redcliffe Power', 643, 'Apartment Building', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		         [15, 14, 1, 0, 'Empty Lot', 'Empty Lot', '', '', 1, 1, 0, 0, 0, 0, 0, 0, 20, 'Lower Harriston Heights', 1, 1, 0, '', 644, 'Empty Lot', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		         [15, 15, 1, 1, 'Warehouse', 'Warehouse', '', '', 1, 2, 0, 0, 0, 0, 0, 1, 30, 'Lower Harriston Heights', 1, 1, 890, 'Redcliffe Power', 645, 'Warehouse', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		         [15, 16, 1, 1, 'The Green Gigolo', 'Restaurant', '', '', 1, 1, 0, 0, 0, 0, 0, 1, 30, 'Lower Harriston Heights', 1, 1, 67, 'Redcliffe Power', 646, 'Restaurant', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		         [16, 12, 1, 1, 'Harriston Public Library', 'Library', '', '', 1, 1, 0, 0, 0, 0, 0, 0, 30, 'Lower Harriston Heights', 1, 1, 129, 'Redcliffe Power', 687, 'Library', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		         [16, 14, 1, 1, 'Redcliffe Power', 'Power Plant', '', '', 1, 1, 0, 0, 0, 0, 0, 0, 30, 'Lower Harriston Heights', 1, 1, 133, 'Redcliffe Power', 689, 'Power Plant', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		         [16, 15, 1, 1, 'Warehouse', 'Warehouse', '', '', 1, 1, 0, 0, 0, 0, 0, 1, 30, 'Lower Harriston Heights', 1, 1, 259, 'Redcliffe Power', 690, 'Warehouse', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', ''],
		         [17, 15, 1, 1, 'Farmer\'s Baked Goods', 'Factory', '', '', 1, 1, 0, 0, 0, 0, 1, 0, 30, 'Lower Harriston Heights', 1, 1, 6, 'Redcliffe Power', 735, 'Factory', 0, 0, 0, '', '', '', '', '', '', 0, '', '', '', '', '', '']]


		alpha.each do |row|


			#exterior
			tile = Entity::Tile.new
			type = Entity::TileType.where(name: row[5]).first
			tile.type = type
			tile.name = row[4]
			tile.x = row[0]
			tile.y = row[1]
			#tile.description = row[5]
			tile.z = 0
			tile.plane = 3
			tile.save
			#interior
			if row[2] == 1
				tile = Entity::Tile.new
				type = Entity::TileType.where(name: row[5] + ' (Inside)').first
				tile.type = type
				tile.name = row[4]
				tile.x = row[0]
				tile.y = row[1]
				#tile.description = row[6]
				tile.z = 1
				tile.plane = 3
				tile.save
			end
		end
	end


end