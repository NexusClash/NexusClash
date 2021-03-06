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
		super addr, :game, false
	end

	TABLE_FOR_ESCAPE_HTML__ = {
			"'" => '&#39;',
			'&' => '&amp;',
			'"' => '&quot;',
			'<' => '&lt;',
			'>' => '&gt;',
	}

	def debug_msg(msg, type)
		@debug_bar ||= $document.at_css('#debugbar')
		@debug_node ||= $document.at_css('#debugbar ul')
		@debug_i ||= 0
		@debug_i += 1
		if @debug_i > 200 && $document.at_css('#debug_mode:checked') === nil
			@debug_node.inner_html = ''
			@debug_i = 0
		end
		node = DOM{li}
		node.attributes[:class] = type
		node.attributes[:tabindex] = 0
		node.inner_html = msg.to_json.gsub(/[&\"<>]/, TABLE_FOR_ESCAPE_HTML__).gsub('\n', '<br/>').gsub('\t', '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;').gsub("\\'", "'")
		node.append_to @debug_node
		debug_native = Native.convert @debug_bar
		`debug_native.scrollTop = debug_native.scrollHeight`
	end

	def write_message(msg)
		super msg
		debug_msg msg, :transmitted
	end

	def write_messages(msgs)
		super msgs
		debug_msg msgs, :transmitted
	end

	def handle_message(m)
		JSON.parse(m.data)[:packets].each do |ent|
			debug_msg(ent, :informational) unless ent[:type] == 'error' ||  ent[:type] == 'debug'
			case ent[:type]
				when 'authentication_request'
					$document.at_css('#game_loading .message').inner_html = 'Authenticating...'
					char_id = $document.at_css('#char_id').inner_html.to_s.strip
					write_message({type: 'connect', char_id: char_id})
				when 'debug', 'error'
					debug_msg ent['message'].gsub('\\n', '<br/>'), ent[:type]
					$document.at_css('#game_loading .message').inner_html = ent['message'].replace('\\n', '<br/>')
				when 'self'
					if @adventurer === nil then
						$document.at_css('#game_loading .message').inner_html = 'Loading character...'
						@adventurer = Adventurer.new ent['character'], true
						@luggage = Luggage.new
					else
						@adventurer.update ent['character']
						@adventurer.render
						$document.at_css('#activity_log ul').inner_html = ''
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
					$document.at_css('#game_loading').attributes[:class] = 'ui-helper-hidden'
					$document.at_css('#game').attributes[:class] = ''
					data = ent['tile']
					target = @adventurer.map.surrounds[data['x'] - @adventurer.x][data['y'] - @adventurer.y]
					unless target === nil || (target.z != data['z'] && @adventurer.z != data['z']) then
						target.colour = data['colour'] if data.has_key? 'colour'
						target.name = data['name'] if data.has_key? 'name'
						target.type = data['type'] if data.has_key? 'type'
						target.is_day = data['is_day'] if data.has_key? 'is_day'

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
						$document.at_css('#tile_description').inner_html = "<h4><img class='tile-time-indicator' src='/img/Time-#{target.is_day ? 'Day' : 'Night'}.gif'/> #{target.name} (#{target.x}, #{target.y}, <a href='/autowiki/tile/#{target.x}/#{target.y}/#{target.z}' target='_blank' style='color:black'>#{target.type}</a>)</h4><p>#{target.description}</p><p>There #{target.occupants == 1 ? 'is' : 'are'} #{target.occupants} other #{target.occupants == 1 ? 'person' : 'people'} here.</p>" if target.x == @adventurer.x && target.y == @adventurer.y && target.z == @adventurer.z
					end
				when 'actions'
					action_mode = :replace
					action_mode = ent['mode'].to_sym if ent.has_key? 'mode'
					if ent['actions'].has_key? 'attacks'
						if action_mode == :update
							data = ent['actions']['attacks']
							data.keys.each do |action_id|
								action = data[action_id]
								next if action['name'] == ''
								option = $document.at_css("#target_information #action_attack option[value='#{action_id}']")
								unless option === nil
									option.inner_html = "#{action['name']} - #{action['damage']} #{action['damage_type']} @ #{action['hit_chance']}%"
								end
							end
						else
							oldweap = $document.at_css('#action_attack option:checked')
							if oldweap === nil
								oldweap = 0
							else
								oldweap = oldweap.attributes[:value]
							end
							weap_index = 0

							html = "<li><button data-action-type='attack' data-action-vars='target:#{@adventurer.target.id},target_type:#{@adventurer.target.type}' data-action-user-vars='weapon:#action_attack option:checked,charge_attack:.charge_attack:checked'>Attack with</button> <select id='action_attack'>"

							data = ent['actions']['attacks']
							weapi = 0
							data.keys.each do |action_id|
								action = data[action_id]
								next if action['name'] == ''
								weap_index = weapi if oldweap == action_id
								weapi += 1
								html = html + "<option value='#{action_id}'>#{action['name']} - #{action['damage']} #{action['damage_type']} @ #{action['hit_chance']}%</option>"
							end
							html = html + '</select></li>'
							$document.at_css('#target_information .attacks').inner_html = html
							attacks_node = $document.at_css('#target_information #action_attack')
							if weap_index != 0
								attacks_node = Native.convert attacks_node
								weap_index = Native.convert weap_index
								`attacks_node.selectedIndex = weap_index`
							end
						end

					end
					if ent['actions'].has_key? 'charge_attacks'
						html = ''
						if ent['actions']['charge_attacks'].count > 0
							html = html + '<li style="margin:5px;padding-bottom:5px;border-bottom:1px dashed grey">'
						else
							html = html + '<li style="display:none">'
						end
						html = html + '&rdsh; with: <input type="radio" id="charge_attack_none" name="charge_attack" class="charge_attack" value="" checked><label for="charge_attack_none" class="ui-button">None</label>'
						data = ent['actions']['charge_attacks']
						data.keys.each do |action_id|
							action = data[action_id]
							next if action['name'] == ''
							disabledUnlessActionPossible = action['possible'] ? '' : 'disabled'
							html = html + "<input type='radio' #{disabledUnlessActionPossible} id='charge_attack_#{action_id}' name='charge_attack' class='charge_attack' value='#{action_id}'><label class='ui-button #{disabledUnlessActionPossible}' for='charge_attack_#{action_id}' title='#{action['description']}'>#{action['name']}</label>"
						end
						html = html + '</li>'
						$document.at_css('#target_information .charge_attacks').inner_html = html
					end
					if ent['actions'].has_key? 'abilities'
						html = ''
						data = ent['actions']['abilities']
						data.keys.each do |action_id|
							action = data[action_id]
							next if action['name'] == ''
							html = html + "<li><button data-action-type='activate_target' data-action-vars='status_id:#{action_id},target:#{@adventurer.target.id},target_type:#{@adventurer.target.type}'>#{action['name']}</button></li>"
						end
						$document.at_css('#target_information .abilities').inner_html = html
					end
				when 'message'

					node = DOM{
						li
					}
					node['data-message-family'] = ent['class']
					$document.at_css('#css-tab-r1').trigger :click if ent['class'] == 'step-inside' || ent['class'] == 'step-outside'
					node.inner_html = ent['message'] + ' <sup>(' + Time::at(ent['timestamp'].to_i).strftime('%Y-%m-%d %H:%M:%S') + ')</sup>'
					target_node = Native.convert $document.at_css('#activity_log ul')
					native_node = Native.convert node

					if `target_node.firstChild == null`
						`target_node.appendChild(native_node)`
					else
						`target_node.insertBefore(native_node, target_node.firstChild)`
					end

					native_node = Native.convert $document.at_css('#activity_log')
					`native_node.scrollTop = 0`

					write_message({type:'request_crafting_recipes'}) if ent['class'] == MessageType::CRAFT_SUCCESS.to_s
				when 'portals'
					tile_portals = $document.at_css('#tile_portals')
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
					$document.at_css('#skill_tree').inner_html = '<h4>Skill Tree</h4><button data-action-type="request_classes">Classes</button>'

					root.append_to($document.at_css('#skill_tree'))

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


					$document.at_css('#skill_tree').inner_html = '<h4>Classes</h4><button data-action-type="request_skill_tree">Return to Skill Tree</button>'
					root.append_to($document.at_css('#skill_tree'))

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
					$document.at_css('#target_information .tname').value = ent['tile']['name']
					$document.at_css('#target_information .x').inner_html = ent['tile']['x']
					$document.at_css('#target_information .y').inner_html = ent['tile']['y']
					$document.at_css('#target_information .z').inner_html = ent['tile']['z']
					$document.at_css('#target_information .description').inner_html = "<textarea>#{ent['tile']['description']}</textarea>"
					$document.at_css('#target_information .z')['data-type'] = ent['tile']['type']
					$document.at_css('#target_information .tile')['data-type'] = ent['tile']['type']
					html = ''

					ent['types'].each do |tid, tval|
						html = html + "<option value='#{tid}' #{tid.to_i == ent['tile']['type_id'].to_i ? 'selected="selected"' : ''}>#{tval}</option>"
					end
					$document.at_css('#target_information .type_id').inner_html = html
					$document.at_css('#target_information')['data-target-type'] = 'tile_dev'
					$document.at_css('#css-tab-r3').trigger :click
				when 'developer_mode'
					if ent['toggle'] == 'on'
						developer_mode = true
						$document.at_css('#developer_mode_message').attributes[:class] = ''
					else
						developer_mode = false
						$document.at_css('#developer_mode_message').attributes[:class] = 'ui-helper-hidden'
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
							xp_gain = -(recipe['costs'][:xp] || 0)

							unless xp_gain.nil? || xp_gain <= 0
								html = html + '<span class="xp">Grants ' + xp_gain.to_s + ' XP</span>'
							end

							recipe['costs'].each do |name, q|
								next if name == :xp && q <= 0
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


					$document.at_css('#crafting_recipe_list').inner_html = ''
					root.append_to($document.at_css('#crafting_recipe_list'))
			end
		end
	end

	def attach_html_bindings
		super

		$document.on :click, '[data-char-link]' do |event|
			return unless state == :connected
			return unless event.button == 0 || event.button == 1
			if adventurer.neighbours.has_key? event.target['data-char-link'].to_i
				$document.at_css('#css-tab-r3').trigger :click
				$document.at_css('#target_information')['data-target-type'] = 'character'
				target = adventurer.neighbours[event.target['data-char-link'].to_i]
				adventurer.target = target
				adventurer.render
				write_message({type: 'select_target', char_id: target.id})
			end
			event.prevent
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
				packet[:x] += adventurer.x
				packet[:y] += adventurer.y
				packet[:z] += adventurer.z
				write_message(packet)
			end

		end

		$document.on :click, '#hud_player_vitals .ui-hud-cp' do |event|
			if state == :connected
				$document.at_css('#play_pane').attributes[:class] = 'ui-helper-hidden'
				$document.at_css('#skills_pane').attributes[:class] = ''
				$document.at_css('#crafting_pane').attributes[:class] = 'ui-helper-hidden'
				write_message({type: 'request_skill_tree'})
			end
		end

		$document.on :click, '.return_to_game' do |event|
			$document.at_css('#play_pane').attributes[:class] = ''
			$document.at_css('#skills_pane').attributes[:class] = 'ui-helper-hidden'
			$document.at_css('#crafting_pane').attributes[:class] = 'ui-helper-hidden'
		end

		$document.on :click, '#view_crafting_recipes' do |event|
			if state == :connected
				$document.at_css('#play_pane').attributes[:class] = 'ui-helper-hidden'
				$document.at_css('#skills_pane').attributes[:class] = 'ui-helper-hidden'
				$document.at_css('#crafting_pane').attributes[:class] = ''
				write_message({type: 'request_crafting_recipes'})
			end
		end
	end
end

$document.at_css('#css-tab-r1').trigger :click

$document.at_css('#game_loading .message').inner_html = 'Connecting...'

voyager = Voyager.new Instance.endpoint
