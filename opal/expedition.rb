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

require 'instance'
require 'magellan'

class Expedition

	attr_reader :state

	def developer_mode
		@developer_mode
	end

	def mode
		@mode
	end

	def mode=(val)
		@mode = val
		Tile.event_mode = val # need to make this not global, although not urgent seeing as we only ever have one Expedition instance
	end

	def developer_mode=(val)
		@developer_mode = val
		Tile.developer_mode = val
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

	def initialize(addr, mode, developer_mode = false)
		self.mode = mode
		self.developer_mode = developer_mode
		@address = addr
		@req_in_air = false
		@recon_delay = 3
		@recon_delay_min = 3
		@recon_delay_max = 6
		self.connect
		attach_html_bindings
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
	end

	def attach_html_bindings
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