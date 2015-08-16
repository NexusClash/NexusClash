require 'opal'
require 'browser'
require 'browser/socket'
require 'browser/console'
require 'browser/dom'
require 'browser/dom/document'
require 'browser/http'
require 'browser/dom/event'
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
	end
	def render
		@node.inner_html = 'test'
	end
end

class Luggage

	def initialize(binding = nil, encumbrance_binding = nil)
		binding = $document['#inventory_accordion'] if binding === nil
		encumbrance_binding = $document['#inventory .encumbrance'] if encumbrance_binding === nil
		@categories = Hash.new
		@binding = binding
		@nodes = Hash.new
		@node_encumbrance = encumbrance_binding
		encumbrance_binding.inner_html = 'Encumbrance: 15/50'
	end

	def add_category(cat)
		@categories[cat] = Array.new
		node = DOM{
			li
		}
		node.inner_html = "<input id='inv-category-#{cat}' name='inv-category-#{cat}' type='checkbox' checked='checked'/><label for='inv-category-#{cat}'>#{cat}</label><article id='inv-list-#{cat}'><ol></ol></article>"
		node.append_to @binding
		@nodes[cat] = $document["#inv-list-#{cat} ol"]
	end

	def test
		add_category 'Other'
		add_category 'Weapons'
		add_category 'Worn'
		a = Item.new @nodes['Other']
		a.render
		a = Item.new @nodes['Other']
		a.render
		a = Item.new @nodes['Other']
		a.render
		a = Item.new @nodes['Weapons']
		a.render
		a = Item.new @nodes['Weapons']
		a.render
		a = Item.new @nodes['Weapons']
		a.render
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

	def initialize(addr)

		unless Browser::Socket.supported?
			@state = :unsupported
			return
		end

		@state = :connecting

		@socket = Browser::Socket.new addr do |socket|

			socket.on :open do
				@state = :connected
				$document['#game_loading .message'].inner_html = 'Connected!'
			end

			socket.on :message do |e|
				puts e.data
				handle_message e
			end

			socket.on :error do
				@state = :error
			end

			socket.on :close do
				@state = :closed
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
						@luggage.test
						write_messages([{type: 'refresh_map'}, {type: 'sync_messages', from: (Time.now - (2*24*60*60))}])
					else
						@adventurer.update ent['character']
						@adventurer.render
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
					$document['#activity_log ul'].inner_html = '<li data-message-family="' + ent['class'] + '">- ' + ent['message'] + ' <sup>(' + Time::at(ent['timestamp'].to_i).strftime('%Y-%m-%d %H:%M:%S') + ')</sup></li>' + $document['#activity_log ul'].inner_html
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
	$document[event.target['data-enter-trigger-action']].trigger :click if target.code == 13
end

$document.on :click, '#hud_player_vitals .ui-hud-cp' do |event|
	$document['#play_pane'].attributes[:class] = 'ui-helper-hidden'
	$document['#skills_pane'].attributes[:class] = ''
	voyager.write_message({type: 'request_skill_tree'})
end

$document.on :click, '.return_to_game' do |event|
	$document['#play_pane'].attributes[:class] = ''
	$document['#skills_pane'].attributes[:class] = 'ui-helper-hidden'
end