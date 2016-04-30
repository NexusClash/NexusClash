require 'opal'
require 'browser'
require 'browser/socket'
require 'browser/console'
require 'browser/dom'
require 'browser/dom/document'
require 'browser/http'
require 'browser/delay'
require 'browser/event'
require 'native'
require 'message_type'

require 'adventurer'
require 'luggage'
require 'instance'
require 'expedition'

class Voyager < Expedition

	attr_accessor :adventurer
	attr_accessor :luggage


	def initialize(addr)
		super addr, :game
	end

	def handle_message(m)
		JSON.parse(m.data)[:packets].each do |ent|
			case ent[:type]
				when 'authentication_request'
					$document['#game_loading .message'].inner_html = 'Authenticating...'
					char_id = $document['char_id'].inner_html.to_s.strip
					write_message({type: 'connect', char_id: char_id})
				when 'debug', 'error'
					puts "#{ent[:type]}: #{ent['message']}"
					$document['#game_loading .message'].inner_html = ent['message'].replace('\\n', '<br/>')
				when 'self'
					if @adventurer === nil then
						$document['#game_loading .message'].inner_html = 'Loading character...'
						@adventurer = Adventurer.new ent['character'], true
						@luggage = Luggage.new
					else
						@adventurer.update ent['character']
						@adventurer.render
						$document['#activity_log ul'].inner_html = ''
					end
					write_messages([{type: 'refresh_map'}, {type: 'sync_messages', from: (Time.now - (2*24*60*60))}, {type: 'refresh_inventory'}])
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
						# If we don't have the tile type's CSS loaded then request from server
						if data.has_key?('type') && !Tile.style_loaded?(data['type'])
							write_message({type: 'request_tile_css', coordinates: {x: data['x'], y: data['y'], z:data['z']}})
							#Cheat by adding a blank entry - This stops us from requesting the same tile over and over if we already have it
							Tile.add_style data['type'], ''
						end
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
						$document['tile_description'].inner_html = "<h4>#{target.name} (#{target.x}, #{target.y}, #{target.type})</h4><p>#{target.description}</p><p>There #{target.occupants == 1 ? 'is' : 'are'} #{target.occupants} other #{target.occupants == 1 ? 'person' : 'people'} here.</p>" if target.x == @adventurer.x && target.y == @adventurer.y && target.z == @adventurer.z
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

					native_node = Native.convert $document['#activity_log']
					`native_node.scrollTop = 0`

					write_message({type:'request_crafting_recipes'}) if ent['class'] == MessageType::CRAFT_SUCCESS.to_s
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

					#TODO: Make a skill tree class

					root = DOM{
						ul
					}

					root.attributes[:class] = 'list-plain'

					append = lambda { |parent, item|

						node = DOM{
							li
						}

						if item['type'] == 'class'
							node.inner_html = "<h4><img style='display:inline;width:30px;margin-right:5px;margin-bottom:-8px;' src='/img/class/black/#{item['name']}.png'>#{item['name']} Skills</h4>"
						else

							if item['learned']
								node.inner_html = "<button style='background:#444;color:#EEE'>#{item['name']}</button>"
							else
								node.inner_html = "<button data-action-type='learn_skill' data-action-vars='id:#{item['id']}'>#{item['name']}(#{item['cost']}CP)</button>"
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
					$document['#skill_tree'].inner_html = '<h4>Skill Tree</h4><button data-action-type="request_classes">Classes</button>'

					root.append_to($document['#skill_tree'])

					ent['tree'].each do |skill|

						append.call(root, skill)

					end
				when 'class_choices'

					#TODO: Make a class choices class

					root = DOM{
						ul
					}

					root.attributes[:class] = 'grid cs-style-4 character-select'


					if ent['classes'].count == 0
						node = DOM{
							li
						}
						node.inner_html = 'You are unable to choose an additional class at this time.'

						node.append_to(root)
					end

					ent['classes'].each do |nexus_class|
						node = DOM{
							li
						}

						ctex = ''

						nexus_class['attributes'].each do |line|
							ctex += "<li>#{line}</li>"
						end

						ctex = "<figure><div><img src='/img/class/colour/#{nexus_class['name']}.png'/><div><p>#{nexus_class['name']}</p></div></div><figcaption><h3>Choose Class</h3><span>Tier #{nexus_class['tier']} Class</span><ul class='list-plain'>#{ctex}</ul><p><button data-action-type='learn_skill' data-action-vars='id:#{nexus_class['id']}'>Become a #{nexus_class['name']}</button></p></figcaption></figure>"


						node.inner_html = ctex

						node.append_to(root)
					end


					$document['#skill_tree'].inner_html = '<h4>Classes</h4><button data-action-type="request_skill_tree">Return to Skill Tree</button>'
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
				when 'tile_css'
					Tile.add_style ent['tile'], ent['css']
				when 'warp'
					url = Native.convert ent['url']
					`window.location = url`
				when 'crafting_recipes'

					#TODO: Make a recipes class

					root = DOM{
					}

					ent['recipes'].each do |recipe|

						node = DOM{
							div.crafting_recipe
						}

						node['data-craftable'] = 1 if recipe['possible']

						html = "<h4>#{recipe['name']}</h4>"

						missing_reagents = recipe['reagents_missing']
						missing_catalysts = recipe['catalysts_missing']

						if recipe['outputs'].size > 0

							html = html + '<span class="outputs"><span>Creates </span><ul>'

							recipe['outputs'].each do |name, q|
								html = html + "<li>#{q} x #{name}</li>"
							end

							html = html + '</ul></span>'

						end

						costs = ''

						if recipe['costs'].size > 0

							recipe['costs'].each do |name, q|
								costs = costs + "#{q} #{name.to_s.upcase},"
							end

							costs = " (#{costs.chomp(',')})"

						end

						if recipe['catalysts'].size > 0

							html = html + '<span class="catalysts"><span>Requires </span><ul>'

							recipe['catalysts'].each do |name, q|
								html = html + "<li #{missing_catalysts.has_key?(name) ? "data-craft-missing='#{missing_catalysts[name]}'" : 'data-craft-missing="0"'}'>#{q} x #{name}#{missing_catalysts.has_key?(name) ? '(' + missing_catalysts[name].to_s + ' missing)' : ''}</li>"
							end

							html = html + '</ul></span>'

						end

						if recipe['reagents'].size > 0

							html = html + '<span class="reagents"><span>Consumes </span><ul>'

							recipe['reagents'].each do |name, q|
								html = html + "<li style='background-color:#{missing_reagents.has_key?(name) ? '#FFEEEE' : '#EEFFEE'}'>#{q} x #{name}#{missing_reagents.has_key?(name) ? '(' + missing_reagents[name].to_s + ' missing)' : ''}</li>"
							end

							html = html + '</ul></span>'

						end

						if recipe['possible']
							html = html + "<button data-action-type='craft' data-action-vars='id:#{recipe['id']}'>Craft#{costs}</button>"
						else
							html = html + "<button disabled data-action-type='craft' data-action-vars='id:#{recipe['id']}'>Craft#{costs}</button>"
						end

						node.inner_html = html
						node.append_to root
					end


					$document['#crafting_recipe_list'].inner_html = ''
					root.append_to($document['#crafting_recipe_list'])
			end
		end
	end
end

$document['css-tab-r1'].trigger :click

$document['#game_loading .message'].inner_html = 'Connecting...'

voyager = Voyager.new Instance.endpoint

puts 'socket opened!'

#$document['map'].on :click, '.tile' do |event|
#	voyager.write_message({type: 'movement', x: event.target['data-x'].to_i, y: event.target['data-y'].to_i, z: event.target['data-z'].to_i})
#end

$document.on :click, 'span[data-char-link]' do |event|
	return unless voyager.state == :connected
	return unless event.button == 0 || event.button == 1
	if voyager.adventurer.neighbours.has_key? event.target['data-char-link'].to_i
		$document['css-tab-r3'].trigger :click
		$document['target_information']['data-target-type'] = 'character'
		target = voyager.adventurer.neighbours[event.target['data-char-link'].to_i]
		voyager.adventurer.target = target
		voyager.adventurer.render
		voyager.write_message({type: 'target', char_id: target.id})
	end
end

#$document.on :click, '#speech_action button' do |event|
#	voyager.write_message({type: 'speech', message: $document['#speech_action input'].value})
#	$document['#speech_action input'].value = ''
#end


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
	$document['#crafting_pane'].attributes[:class] = 'ui-helper-hidden'
	voyager.write_message({type: 'request_skill_tree'})
end

$document.on :click, '.return_to_game' do |event|
	$document['#play_pane'].attributes[:class] = ''
	$document['#skills_pane'].attributes[:class] = 'ui-helper-hidden'
	$document['#crafting_pane'].attributes[:class] = 'ui-helper-hidden'
	return unless voyager.state == :connected
end

$document.on :click, '#view_crafting_recipes' do |event|
	return unless voyager.state == :connected
	$document['#play_pane'].attributes[:class] = 'ui-helper-hidden'
	$document['#skills_pane'].attributes[:class] = 'ui-helper-hidden'
	$document['#crafting_pane'].attributes[:class] = ''
	voyager.write_message({type: 'request_crafting_recipes'})
end