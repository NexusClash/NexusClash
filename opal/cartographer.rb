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

require 'adventurer'
require 'instance'
require 'expedition'

class Cartographer < Expedition

	attr_accessor :map

	attr_accessor :map_x
	attr_accessor :map_y
	attr_accessor :map_z

	attr_accessor :zoom
	attr_accessor :size

	def initialize(addr)
		@size = 50
		@map_z = 0
		@map_x = -20
		@map_y = 20
		self.zoom = 0.5
		@map = Magellan.new $document['#map_edit_view'], @size
		super addr, :editor, true
	end

	def zoom=(zoom)
		@zoom = zoom
		px = zoom * 75
		css = "#map_edit_container{max-height:80vh} #map_edit_view{width:#{px * @size * 2 + px * 2 + @size * 2 + 80}px; height:#{px * @size * 2 + px * 2 + @size * 2}px}  #map_edit_view .tile {width: #{px}px; height: #{px}px; max-width:#{px}px !important} "
		$document['#map_editor_zoom'].inner_html = css
	end

	def handle_message(m)
		JSON.parse(m.data)[:packets].each do |ent|
			case ent[:type]
				when 'authentication_request'
					$document['#game_loading .message'].inner_html = 'Authenticating...'
					write_message({type: 'connect', admin: true})
				when 'debug', 'error'
					puts "#{ent[:type]}: #{ent['message']}"
					$document['#game_loading .message'].inner_html = ent['message'].replace('\\n', '<br/>')
				when 'developer_mode'
					$document['#game_loading'].attributes[:class] = 'ui-helper-hidden'
					$document['#game'].attributes[:class] = ''

					# Request map
					write_message({type: 'admin_map_load', x: @map_x - @size, y: @map_y - @size, z: @map_z, w: @size * 2 + 1, h: @size * 2 + 1})

				when 'tile', 'admin_tile', 'dev_tile'

					if ent['type'] == 'dev_tile'
						if @click_x == ent['tile']['x'].to_i && @click_y == ent['tile']['y'].to_i
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
							$document['css-tab-r1'].trigger :click
						end
					end

					data = ent['tile']

					target = @map.surrounds[data['x'] - @map_x][data['y'] - @map_y]
					unless target === nil || (target.z != data['z'] && @map_z != data['z']) then
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
						target.type_id = data['type_id'].to_i if data.has_key? 'type_id'
						target.description = data['description'] if data.has_key? 'description'
						target.render
					end
				when 'developer_mode'
					if ent['toggle'] == 'on'
						self.developer_mode = true
						$document['#developer_mode_message'].attributes[:class] = ''
					else
						self.developer_mode = false
						$document['#developer_mode_message'].attributes[:class] = 'ui-helper-hidden'
					end
				when 'tile_css'
					Tile.add_style ent['tile'], ent['css']
			end
		end
	end

	def attach_html_bindings
		$document.on :click, '#zoom_in' do |event|

			if zoom < 1
				zoom += 0.1
			else
				zoom += 1
			end
		end

		$document.on :click, '#zoom_out' do |event|
			if zoom > 2
				zoom -= 1
			else
				if zoom > 0.1
					zoom -= 0.1
				end
			end

		end

		$document.on :click, '#map_edit_view .tile' do |event|
			if state == :connected
				if event.button == 2
					#right click - select tile as the clone source if the multiple tile stamping tab is open
					unless $document['#css-tab-r2:checked'] === nil

						x = event.target['data-x'].to_i - map_x
						y = event.target['data-y'].to_i - map_y

						tile = map.surrounds[x][y]

						$document['#edit_tile_multiple input[name=stamp-name'].value = tile.name
						$document['#edit_tile_multiple .description textarea'].value = tile.description
						$document['#edit_tile_multiple .tile']['data-type'] = tile.type
						$document['#edit_tile_multiple #stamp_type'].inner_html = tile.type
						$document['#edit_tile_multiple input[name=stamp-type]'].value = tile.type_id
						$document['#edit_tile_multiple']['data-target-type'] = 'tile_dev'

					end

					event.stop
				else
					unless $document['#css-tab-r1:checked'] === nil
						# Single tile edit mode
						@click_x = event.target['data-x'].to_i
						@click_y = event.target['data-y'].to_i
						write_message({type: 'dev_tile', x: event.target['data-x'], y: event.target['data-y'], z: event.target['data-z']})
					else
						# Tile stamping mode
						changes = {type: 'dev_tile', edit: true, x: event.target['data-x'].to_i, y: event.target['data-y'].to_i, z: event.target['data-z'].to_i}
						changes['name'] = $document['#edit_tile_multiple  input[name=stamp-name'].value unless $document['#edit_tile_multiple input[name=use-stamp-name]:checked'] === nil
						changes['type_id'] = $document['#edit_tile_multiple  input[name=stamp-type]'].value unless $document['#edit_tile_multiple input[name=use-stamp-type]:checked'] === nil

						unless $document['#edit_tile_multiple input[name=use-stamp-description]:checked'] === nil
							node = $document['#edit_tile_multiple .description textarea'].value
							native_node = Native.convert node
							changes['description'] = `node.value`
						end
						write_message(changes)
					end
					event.stop
				end
			end
		end


		$document.on :click, 'button[data-action-type], .action[data-action-type]' do |event|
			if self.state == :connected && (((event.button == 0 || event.button == 1) && event.target['data-action-type'] != nil) || (event.button == 2 && developer_mode && event.target['data-dev-action-type'] != nil))
				target = event.target['data-action-type']
				defined = event.target['data-action-vars']
				user_defined = event.target['data-action-user-vars']
				post_event_click = event.target['data-action-trigger-click']

				if developer_mode && event.target['data-dev-action-type'] != nil && event.button == 2
					target = event.target['data-dev-action-type']
					defined = event.target['data-dev-action-vars']
					user_defined = event.target['data-dev-action-user-vars']
					post_event_click = event.target['data-dev-action-trigger-click']
				end

				return if target == 'move'

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
				self.write_message(packet)
				$document[post_event_click].trigger :click if post_event_click != nil
			end
		end

		$document.on :keyup, 'input[data-enter-trigger-action]' do |event|
			$document[event.target['data-enter-trigger-action']].trigger :click if event.code == 13
		end


	end
end

$document['css-tab-r1'].trigger :click

$document['#game_loading .message'].inner_html = 'Connecting...'

cartographer = Cartographer.new Instance.endpoint