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

require 'adventurer'

puts 'wow, running ruby!'

class Voyager

	attr_reader :state
	attr_accessor :map

	attr_accessor :map_x
	attr_accessor :map_y
	attr_accessor :map_z

	attr_accessor :zoom
	attr_accessor :size

	def self.developer_mode
		true
	end

	def self.mode
		:editor
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
		@size = 25
		@map_z = 0
		@map_x = 20
		@map_y = 20
		self.zoom = 0.5
		@map = Magellan.new $document['#map_edit_view'], @size
		self.connect
	end

	def zoom=(zoom)
		@zoom = zoom
		px = zoom * 75
		css = "#map_edit_container{max-height:80vh} #map_edit_view{width:#{px * @size * 2 + px * 2 + @size * 2 + 80}px; height:#{px * @size * 2 + px * 2 + @size * 2}px}  #map_edit_view .tile {width: #{px}px; height: #{px}px; max-width:#{px}px !important} "
		$document['#map_editor_zoom'].inner_html = css
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
				#puts e.data
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
					write_message({type: 'connect', admin: true})
				when 'debug'
					puts 'debug: ' + ent['message']
					$document['#game_loading .message'].inner_html = ent['message'].replace('\\n', '<br/>')
				when 'error'
					puts 'error: ' + ent['message']
					$document['#game_loading .message'].inner_html = ent['message'].replace('\\n', '<br/>')
				when 'developer_mode'
					$document['#game_loading'].attributes[:class] = 'ui-helper-hidden'
					$document['#game'].attributes[:class] = ''

					# Request map
					write_message({type: 'admin_map_load', x: @map_x - @size, y: @map_y - @size, z: @map_z, w: @size * 2 + 1, h: @size * 2 + 1})

				when 'tile', 'admin_tile'

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
						target.description = data['description'] if data.has_key? 'description'
						target.render
					end
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
			end
		end
	end
end

$document['css-tab-r1'].trigger :click

$document['#game_loading .message'].inner_html = 'Connecting...'

voyager = Voyager.new 'ws://ruby.windrunner.mx:4020/42'

puts 'socket opened!'

$document.on :click, '#zoom_in' do |event|

	if voyager.zoom < 1
		voyager.zoom = voyager.zoom + 0.1
	else
		voyager.zoom = voyager.zoom + 1
	end
end

$document.on :click, '#zoom_out' do |event|
	if voyager.zoom > 2
		voyager.zoom = voyager.zoom - 1
	else
		if voyager.zoom > 0.1
      voyager.zoom = voyager.zoom - 0.1
		end
	end

end
