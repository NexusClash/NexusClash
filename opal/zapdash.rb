require 'opal'
require 'browser'
require 'browser/socket'
require 'browser/console'
require 'browser/dom'
require 'browser/dom/document'
require 'browser/http'
require 'browser/delay'
require 'browser/dom/event'
require 'native'

puts 'wow, running ruby!'

class Tile
	attr_reader :binding
	attr_accessor :type
	attr_accessor :colour
	attr_accessor :name
	attr_accessor :x
	attr_accessor :y
	attr_accessor :z
	attr_accessor :occupants
	attr_accessor :description
	attr_accessor :origin_tile

	def initialize(binding)
		@binding = binding
		@colour = 'black'
		@name = ''
		@type = 'Void'
		@occupants = 0
		@origin_tile = false

		@node = DOM{
			div.tile.action
		}

		@node.append_to(binding)
	end

	def render
		@node['title'] = @name
		@node['tabIndex'] = 0
		@node['data-x'] = @x
		@node['data-y'] = @y
		@node['data-z'] = @z
		@node['data-type'] = @type
		@node['data-action-type'] = 'movement'
		@node['data-action-vars'] = "x:#{@x},y:#{@y},z:#{@z}"
		if Voyager.developer_mode
			@node['data-dev-action-type'] = 'dev_tile'
			@node['data-dev-action-vars'] = "x:#{@x},y:#{@y},z:#{@z}"
			@node['oncontextmenu'] = 'return false;'
		else
			@node['oncontextmenu'] = nil
		end
		@node.inner_html = ''

		@crowd = DOM{
			ul.occupants
		}
		DOM{ li.character.self }.append_to(@crowd) if @origin_tile
		if @occupants > 0
			(1..@occupants).each do |i|
				DOM{ li.character }.append_to(@crowd)
			end
		end
		@crowd.append_to(@node) if @occupants > 0 || @origin_tile
	end
end

class Item
	def initialize(binding)
		@binding = binding
		@node = DOM{
			li
		}
		@node.append_to binding
		@actions = []
	end

	def remove
		@node.remove
	end

	attr_accessor :id, :name, :type, :category, :weight, :actions

	def render
		actions = ''
		@actions.each do |action|
			actions = actions + "<button data-action-type='#{action.type}' data-action-vars='id:#{id.to_s},status_id:#{action.id}'>#{action.name}</button>"
		end
		@node.inner_html = "<span>#{name}<span style='float:right'>#{actions}</span></span><span>#{weight.to_s}</span><span><button data-action-type='drop' data-action-vars='id:#{id.to_s}'>Drop</button></span>"
	end

	class Action
		attr_reader :name, :type, :id

		def initialize(name, type, id)
			@name = name
			@type = type
			@id = id
		end
	end
end

class Luggage

	attr_reader :weight
	attr_reader :weight_max

	def weight=(weight)
		@weight = weight
	end

	def weight_max=(weight_max)
		@weight_max = weight_max
	end

	def initialize(binding = nil, encumbrance_binding = nil)
		binding = $document['#inventory_accordion'] if binding === nil
		encumbrance_binding = $document['#inventory .encumbrance'] if encumbrance_binding === nil
		@categories = Hash.new
		@items_by_id = Hash.new
		@binding = binding
		@nodes = Hash.new
		@node_encumbrance = encumbrance_binding
		self.render
	end

	def clear
		@items_by_id.clear
		@categories.clear
		@nodes.clear
		@binding.clear
	end

	def add_category(cat)
		@categories[cat] = Array.new
		node = DOM{
			li
		}
		node.inner_html = "<input id='inv-category-#{cat}' name='inv-category-#{cat}' type='checkbox' checked='checked'/><label for='inv-category-#{cat}'><span>#{cat.capitalize}</span><span>Wt</span><span></span></label><article id='inv-list-#{cat}'><ol></ol></article>"
		node.append_to @binding
		@nodes[cat] = $document["#inv-list-#{cat} ol"]
	end

	def remove_item(id)
		id = id.to_i
		if @items_by_id.has_key? id
			item = @items_by_id[id]
			@items_by_id.delete id
			@categories[item.category].delete item
			item.remove
			if @categories[item.category].count == 0
				@categories.delete item.category
				@nodes[item.category].remove
				@nodes.delete item.category
			end
		end
	end

	def parse(item_hash)
		id = item_hash['id'].to_i
		if @items_by_id.has_key? id
			item = @items_by_id[item_hash['id']]
			item.actions.clear
		else
			category = item_hash['category'].to_sym
			add_category category unless @categories.has_key? category
			item = Item.new @nodes[category]
			@categories[category] << item
			@items_by_id[id] = item
		end
		item.id = id
		item.name = item_hash['name'] if item_hash.has_key? 'name'
		item.type = item_hash['type'] if item_hash.has_key? 'type'
		item.category = item_hash['category'] if item_hash.has_key? 'category'
		item.weight = item_hash['weight'].to_i if item_hash.has_key? 'weight'
		if item_hash.has_key? 'actions'
			item_hash['actions'].each do |action|
				item.actions << Item::Action.new(action['name'], 'activate_item_self', action['status_id'])
			end
		end
		item.render
		render
	end

	def render
		@node_encumbrance.inner_html = "Encumbrance: #{@weight.to_s}/#{@weight_max.to_s}"
	end

end

class Magellan

	attr_accessor :binding

	attr_accessor :surrounds

	def initialize(binding)
		@binding = binding

		@surrounds = Hash.new{|hash, key| hash[key] = Hash.new}

		(-2..2).each do |y|
			(-2..2).each do |x|
				@surrounds[x][y] = Tile.new @binding
				@surrounds[x][y].origin_tile = x == 0 && y == 0
			end
		end

		render
	end

	def render
		(-2..2).each do |y|
			(-2..2).each do |x|
				@surrounds[x][y].render
			end
		end
	end
end

class Adventurer
	attr_accessor :id, :name, :hp, :hp_fuzzy, :mp, :xp, :level, :mo, :cp, :nexus_class
	attr_accessor :x, :y, :z
	attr_accessor :neighbours, :map, :me, :ap, :target

	def type
		'character'
	end

	def initialize(data, me = false)
		if me
			@map = Magellan.new $document['map']
			@neighbours = Hash.new{|hash, charid| hash[charid] = Adventurer.new({id: charid})}
		end
		@me = me
		self.name = data['name'] if data.has_key? 'name'
		self.hp = data['hp'] if data.has_key? 'hp'
		self.hp_fuzzy = data['hp_fuzzy'] if data.has_key? 'hp_fuzzy'
		self.mp = data['mp'] if data.has_key? 'mp'
		self.xp = data['xp'] if data.has_key? 'xp'
		self.level = data['level'] if data.has_key? 'level'
		self.mo = data['mo'] if data.has_key? 'mo'
		self.cp = data['cp'] if data.has_key? 'cp'
		self.x = data['x'] if data.has_key? 'x'
		self.y = data['y'] if data.has_key? 'y'
		self.z = data['z'] if data.has_key? 'z'
		self.ap = data['ap'] if data.has_key? 'ap'
		self.nexus_class = data['nexus_class'] if data.has_key? 'nexus_class'
		@id = data['id']
		@target = nil
		render
	end

	def x=(x)
		@neighbours = Hash.new{|hash, charid| hash[charid] = Adventurer.new({id: charid})} unless @x == x
		@x = x
	end
	def y=(y)
		@neighbours = Hash.new{|hash, charid| hash[charid] = Adventurer.new({id: charid})} unless @y == y
		@y = y
	end
	def z=(z)
		@neighbours = Hash.new{|hash, charid| hash[charid] = Adventurer.new({id: charid})} unless @z == z
		@z = z
	end

	def update(data)
		self.name = data['name'] if data.has_key? 'name'
		self.hp = data['hp'] if data.has_key? 'hp'
		self.hp_fuzzy = data['hp_fuzzy'] if data.has_key? 'hp_fuzzy'
		self.mp = data['mp'] if data.has_key? 'mp'
		self.xp = data['xp'] if data.has_key? 'xp'
		self.level = data['level'] if data.has_key? 'level'
		self.mo = data['mo'] if data.has_key? 'mo'
		self.cp = data['cp'] if data.has_key? 'cp'
		self.x = data['x'] if data.has_key? 'x'
		self.y = data['y'] if data.has_key? 'y'
		self.z = data['z'] if data.has_key? 'z'
		self.ap = data['ap'] if data.has_key? 'ap'
		self.nexus_class = data['nexus_class'] if data.has_key? 'nexus_class'
		render
	end

	def render
		if @me
			$document['#hud_player_vitals .ap'].inner_html = @ap
			$document['#hud_player_vitals .mp'].inner_html = @mp
			$document['#hud_player_vitals .cp'].inner_html = @cp
			$document['#hud_player_vitals .ui-hud-cp']['data-player-cp'] = @cp
			$document['#hud_player_vitals .mo'].inner_html = @mo
			$document['#hud_player_vitals .xp'].inner_html = @xp
			$document['#hud_player_vitals .hp'].inner_html = @hp
			$document['#hud_player_vitals .level'].inner_html = @level
			$document['#hud_player_vitals .class'].inner_html = @nexus_class
			$document['#hud_player_vitals .name'].inner_html = @name
			occupants = ''
			@neighbours.keys.each do |key|
				neighbour = @neighbours[key]
				occupants += "<li><span data-char-link='#{neighbour.id}'>#{neighbour.name}</span> (#{neighbour.level})<span class='hp-widget' data-state='#{neighbour.hp_fuzzy}'></span></li>"
			end
			$document['tile_occupants_players'].inner_html = occupants
			if @target === nil
				$document['#target_information .name'].inner_html = ''
				$document['#target_information .class_image'].attributes['src'] = ''
				$document['#target_information .stats'].inner_html = ''
				$document['#target_information .actions'].inner_html = ''
			else
				$document['#target_information .name'].inner_html = @target.name
				$document['#target_information .class_image'].attributes['src'] = "/img/class/#{@target.nexus_class}.png"
				$document['#target_information .stats'].inner_html = "<li>Level #{target.level} #{@target.nexus_class}</li><li>HP: #{@target.hp_fuzzy}</li>"
				$document['#target_information .actions'].inner_html = '' unless @neighbours.has_key? @target.id
			end
			if @hp <= 0
				$document['#details_pane_alive'].attributes[:class] = 'ui-helper-hidden'
				$document['#details_pane_dead'].attributes[:class] = ''
			else
				$document['#details_pane_alive'].attributes[:class] = ''
				$document['#details_pane_dead'].attributes[:class] = 'ui-helper-hidden'
			end
		end
	end
end

class Voyager

	attr_reader :state
	attr_accessor :adventurer
	attr_accessor :luggage

	@@developer_mode = false

	def self.developer_mode
		@@developer_mode
	end

	def state=(state)
		return if @state == :error && state == :disconnected
		@state = state
		case state
			when :error, :disconnected
				$window.after @recon_delay do
					unless @req_in_air
						@req_in_air = true
						@recon_delay = @recon_delay + 1 if @recon_delay < @recon_delay_max
						Browser::HTTP.get("/validate/#{$document['char_id'].inner_html.to_s.strip}").then {|resp|
							@req_in_air = false
							if resp.text == 'ok'
								self.connect
							else
								self.state = :error
							end

						}.rescue{
							@req_in_air = false
							self.state = :error
						}
					end

				end
				$document['#ws-connection']['data-state'] = state.to_s
			when :connected
				$document['#ws-connection']['data-state'] = state.to_s
				@recon_delay = @recon_delay_min
			when :unsupported
				$document['#ws-connection']['data-state'] = 'error'
		end
	end

	def initialize(addr)
		@address = addr
		@req_in_air = false
		@recon_delay = 3
		@recon_delay_min = 3
		@recon_delay_max = 6
		self.connect
	end

	def connect
		unless Browser::Socket.supported?
			@state = :unsupported
			return
		end

		self.state = :connecting
		@socket = Browser::Socket.new @address do |socket|

			socket.on :open do
				self.state = :connected
				$document['#game_loading .message'].inner_html = 'Connected!'
			end

			socket.on :message do |e|
				puts e.data
				handle_message e
			end

			socket.on :error do
				self.state = :error
			end

			socket.on :close do
				self.state = :disconnected
			end
		end
	end

	def write_message(msg)
		puts "send - #{msg.to_json}"
		@socket.write({packets: [msg] }.to_json)
	end

	def write_messages(msgs)
		puts "send - #{msgs.to_json}"
		@socket.write({packets: msgs }.to_json)
	end

	def handle_message(m)
		JSON.parse(m.data)[:packets].each do |ent|
			case ent[:type]
				when 'authentication_request'
					$document['#game_loading .message'].inner_html = 'Authenticating...'
					char_id = $document['char_id'].inner_html.to_s.strip
					write_message({type: 'connect', char_id: char_id})
				when 'debug'
					puts 'debug: ' + ent['message']
					$document['#game_loading .message'].inner_html = ent['message'].replace('\\n', '<br/>')
				when 'error'
					puts 'error: ' + ent['message']
					$document['#game_loading .message'].inner_html = ent['message'].replace('\\n', '<br/>')
				when 'self'
					if @adventurer === nil then
						$document['#game_loading .message'].inner_html = 'Loading character...'
						@adventurer = Adventurer.new ent['character'], true
						@luggage = Luggage.new
						write_messages([{type: 'refresh_map'}, {type: 'sync_messages', from: (Time.now - (2*24*60*60))}, {type: 'refresh_inventory'}])
					else
						@adventurer.update ent['character']
						@adventurer.render
						$document['#activity_log ul'].inner_html = ''
						write_messages([{type: 'refresh_map'}, {type: 'sync_messages', from: (Time.now - (2*24*60*60))}, {type: 'refresh_inventory'}])
					end
				when 'character'
					data = ent['character']
					if data['id'] == @adventurer.id
						@adventurer.update data
					else
						@adventurer.neighbours[data['id']].update(data) if data['x'] == @adventurer.x && data['y'] == @adventurer.y && data['z'] == @adventurer.z
					end
					@adventurer.render
				when 'remove_character'
					@adventurer.neighbours.delete ent['char_id']
					@adventurer.render
				when 'tile'
					$document['#game_loading'].attributes[:class] = 'ui-helper-hidden'
					$document['#game'].attributes[:class] = ''
					data = ent['tile']
					target = @adventurer.map.surrounds[data['x'] - @adventurer.x][data['y'] - @adventurer.y]
					unless target === nil || (target.z != data['z'] && @adventurer.z != data['z']) then
						target.colour = data['colour'] if data.has_key? 'colour'
						target.name = data['name'] if data.has_key? 'name'
						target.type = data['type'] if data.has_key? 'type'
						target.x = data['x']
						target.y = data['y']
						target.z = data['z']
						if data.has_key? 'occupants'
							if target.x == @adventurer.x && target.y == @adventurer.y && target.z == @adventurer.z
								target.occupants = data['occupants'].to_i - 1 if data.has_key? 'occupants'
							else
								target.occupants = data['occupants'].to_i if data.has_key? 'occupants'
							end
						end
						target.description = data['description'] if data.has_key? 'description'
						target.render
						$document['tile_description'].inner_html = "<h4>#{target.name} (#{target.x}, #{target.y}, #{target.type})</h4><p>#{target.description}</p><p>There #{target.occupants == 1 ? 'is' : 'are'} #{target.occupants.to_s} other #{target.occupants == 1 ? 'person' : 'people'} here.</p>" if target.x == @adventurer.x && target.y == @adventurer.y && target.z == @adventurer.z
					end
				when 'actions'
					html = "<li><button data-action-type='attack' data-action-vars='target:#{@adventurer.target.id},target_type:#{@adventurer.target.type}' data-action-user-vars='weapon:#action_attack option:checked'>Attack with</button> <select id='action_attack'>"
					data = ent['actions']['attacks']
					data.keys.each do |action_id|
						action = data[action_id]
						html = html + "<option value='#{action_id}'>#{action['name']} - #{action['damage']} #{action['damage_type']} @ #{action['hit_chance']}%</option>"
					end
					html = html + '</select></li>'
					$document['#target_information .actions'].inner_html = html
				when 'message'

					node = DOM{
						li
					}
					node['data-message-family'] = ent['class']
					node.inner_html = ent['message'] + ' <sup>(' + Time::at(ent['timestamp'].to_i).strftime('%Y-%m-%d %H:%M:%S') + ')</sup>'
					target_node = Native.convert $document['#activity_log ul']
					native_node = Native.convert node

					if `target_node.firstChild == null`
						`target_node.appendChild(native_node)`
					else
						`target_node.insertBefore(native_node, target_node.firstChild)`
					end

					$document['#activity_log'].scroll.to({x: 0, y: 0})
				when 'portals'
					tile_portals = $document['#tile_portals']
					case ent['action']
						when 'replace'
							tile_portals.inner_html = ''
					end
					ent['portals'].each do |portal|
						vars = ''
						portal['destination'].each do |key, val|
							vars = vars + ',' unless vars == '' || key == 'type'
							vars = vars + key.to_s + ':' + val.to_s unless key == 'type'
						end
						node = DOM{li}
						node.inner_html = "<button data-action-type='#{portal['destination']['type']}' data-action-vars='#{vars}'>#{portal['name']}</button>"
						node.append_to tile_portals
					end
				when 'skill_tree'

					root = DOM{
						ul
					}

					root.attributes[:class] = 'list-plain'

					append = lambda { |parent, item|

						node = DOM{
							li
						}

						if item['type'] == 'class'
							node.inner_html = "<h4><img style='display:inline;width:30px;margin-right:5px;margin-bottom:-8px;' src='/img/class/#{item['name']}.png'>#{item['name'].to_s} Skills</h4>"
						else

							if item['learned']
								node.inner_html = "<button style='background:#444;color:#EEE'>#{item['name'].to_s}</button>"
							else
								node.inner_html = "<button data-action-type='learn_skill' data-action-vars='id:#{item['id']}'>#{item['name'].to_s}(#{item['cost']}CP)</button>"
							end


						end
						node.attributes[:title] = item["description"]

						node.append_to(parent)



						if item['children'].length > 0

							ulnode = DOM{ ul }
							ulnode.append_to(node)

							item['children'].each do |c|
								append.call(ulnode, c)
							end

						end

					}
					$document['#skill_tree'].inner_html = ''
					root.append_to($document['#skill_tree'])

					ent['tree'].each do |skill|

						append.call(root, skill)

					end
				when 'inventory'
					@luggage.weight = ent['weight'].to_i if ent.has_key? 'weight'
					@luggage.weight_max = ent['weight_max'].to_i if ent.has_key? 'weight_max'
					@luggage.render
					case ent['list']
						when 'clear', 'add', 'update'
							@luggage.clear if ent['list'] == 'clear'
							ent['items'].each do |item|
								@luggage.parse item
							end
						when 'remove'
							ent['items'].each do |item|
								@luggage.remove_item item
							end
					end
				when 'dev_tile'
					$document['#target_information .tname'].value = ent['tile']['name']
					$document['#target_information .x'].inner_html = ent['tile']['x']
					$document['#target_information .y'].inner_html = ent['tile']['y']
					$document['#target_information .z'].inner_html = ent['tile']['z']
					$document['#target_information .description'].inner_html = "<textarea>#{ent['tile']['description']}</textarea>"
					$document['#target_information .z']['data-type'] = ent['tile']['type']
					$document['#target_information .tile']['data-type'] = ent['tile']['type']
					html = ''

					ent['types'].each do |tid, tval|
						html = html + "<option value='#{tid}' #{tid.to_i == ent['tile']['type_id'].to_i ? 'selected="selected"' : ''}>#{tval}</option>"
					end
					$document['#target_information .type_id'].inner_html = html
					$document['#target_information']['data-target-type'] = 'tile_dev'
					$document['css-tab-r3'].trigger :click
				when 'developer_mode'
					if ent['toggle'] == 'on'
						@@developer_mode = true
						$document['#developer_mode_message'].attributes[:class] = ''
					else
						@@developer_mode = false
						$document['#developer_mode_message'].attributes[:class] = 'ui-helper-hidden'
					end
			end
		end
	end
end

$document['css-tab-r1'].trigger :click

$document['#game_loading .message'].inner_html = 'Connecting...'

voyager = Voyager.new 'ws://ruby.windrunner.mx:4020/42'

puts 'socket opened!'

#$document['map'].on :click, '.tile' do |event|
#	voyager.write_message({type: 'movement', x: event.target['data-x'].to_i, y: event.target['data-y'].to_i, z: event.target['data-z'].to_i})
#end

$document.on :click, '[data-char-link]' do |event|
	return unless voyager.state == :connected
	return unless event.button == 0 || event.button == 1
	if voyager.adventurer.neighbours.has_key? event.target['data-char-link']
		$document['css-tab-r3'].trigger :click
		$document['target_information']['data-target-type'] = 'character'
		target = voyager.adventurer.neighbours[event.target['data-char-link']]
		voyager.adventurer.target = target
		voyager.adventurer.render
		voyager.write_message({type: 'target', char_id: target.id})
	end
end

#$document.on :click, '#speech_action button' do |event|
#	voyager.write_message({type: 'speech', message: $document['#speech_action input'].value})
#	$document['#speech_action input'].value = ''
#end

$document.on :click, 'button[data-action-type], .action[data-action-type]' do |event|
	return unless voyager.state == :connected
		return unless event.button == 0 || event.button == 1 || (event.button == 2 && Voyager.developer_mode && event.target['data-dev-action-type'] != nil)

		target = event.target['data-action-type']
		defined = event.target['data-action-vars']
		user_defined = event.target['data-action-user-vars']
		post_event_click = event.target['data-action-trigger-click']

		if Voyager.developer_mode && event.target['data-dev-action-type'] != nil && event.button == 2
			target = event.target['data-dev-action-type']
			defined = event.target['data-dev-action-vars']
			user_defined = event.target['data-dev-action-user-vars']
			post_event_click = event.target['data-dev-action-trigger-click']
		end

		packet = {type: target}
		defined = '' if defined === nil
		defined.split(',').each do |defined_var|
			var = defined_var.split(':', 2)
			packet[var[0]] = var[1]
		end
		user_defined = '' if user_defined === nil
		user_defined.split(',').each do |user_var|
			var = user_var.split(':', 2)
			elem = $document[var[1]]
			case elem.name.downcase
				when 'option'
					packet[var[0]] = elem.attributes[:value]
				when 'input'
					packet[var[0]] = elem.value
					elem.value = '' if elem['type'] == 'text'
				when 'textarea'
					packet[var[0]] = elem.inner_html
				else
					packet[var[0]] = elem.inner_html
			end

		end
		voyager.write_message(packet)
		$document[post_event_click].trigger :click if post_event_click != nil
end

$document.on :keyup, 'input[data-enter-trigger-action]' do |event|
	$document[event.target['data-enter-trigger-action']].trigger :click if event.code == 13
end

$document.on :keyup, '#map .tile' do |event|
	#send - {"type":"movement", "x":"1", "y":"1", "z":"0"}
	packet = nil
	case event.code
		#when 36
		#	packet = {x:-1, y:-1, z:0}
		when 38, 87
			packet = {x:0, y:-1, z:0}
		#when 33
		#	packet = {x:1, y:-1, z:0}
		when 37, 65
			packet = {x:-1, y:0, z:0}
		when 39, 68
			packet = {x:1, y:0, z:0}
		#when 35
		#	packet = {x:-1, y:1, z:0}
		when 40, 83
			packet = {x:0, y:1, z:0}
		#when 34
		#	packet = {x:1, y:1, z:0}
	end
	unless packet === nil
		packet[:type] = 'movement'
		packet[:x] += voyager.adventurer.x
		packet[:y] += voyager.adventurer.y
		packet[:z] += voyager.adventurer.z
		voyager.write_message(packet)
	end

end

$document.on :click, '#hud_player_vitals .ui-hud-cp' do |event|
	return unless voyager.state == :connected
	$document['#play_pane'].attributes[:class] = 'ui-helper-hidden'
	$document['#skills_pane'].attributes[:class] = ''
	voyager.write_message({type: 'request_skill_tree'})
end

$document.on :click, '.return_to_game' do |event|
	$document['#play_pane'].attributes[:class] = ''
	$document['#skills_pane'].attributes[:class] = 'ui-helper-hidden'
end