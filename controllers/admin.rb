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

end