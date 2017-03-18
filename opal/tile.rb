require 'opal'
require 'browser'
require 'browser/socket'
require 'browser/console'
require 'browser/dom'
require 'browser/dom/document'
require 'browser/http'
require 'browser/delay'
require 'native'

puts 'Loading Tile...'

class Tile
	attr_reader :binding
	attr_accessor :type
	attr_accessor :type_id
	attr_accessor :colour
	attr_accessor :name
	attr_accessor :x
	attr_accessor :y
	attr_accessor :z
	attr_accessor :occupants
	attr_accessor :is_day
	attr_accessor :description
	attr_accessor :origin_tile
	attr_accessor :clear_left

	@@css = Hash.new
	@@mode = :game
	@@developer_mode = false

	def initialize(binding)
		@binding = binding
		@colour = 'black'
		@name = ''
		@type = 'Void'
		@occupants = 0
		@is_day = false
		@origin_tile = false
		@clear_left = false
		@type_id = -1

		@node = DOM{
			div.tile.action
		}

		@node.append_to(binding)
	end

	def self.add_style(type, style)
		@@css[type] = style
		$document.at_css('#map_styles').inner_html = $document.at_css('#map_styles').inner_html + style
	end

	def self.style_loaded?(style)
		@@css.has_key? style
	end

	def self.developer_mode=(val)
		@@developer_mode = val
	end

	def self.event_mode=(val)
		@@mode = val
	end

	def render
		@node['title'] = @name
		@node['tabIndex'] = 0
		@node['data-x'] = @x
		@node['data-y'] = @y
		@node['data-z'] = @z
		@node['data-type'] = @type
		@node['style'] = 'clear:left' if @clear_left
		@node.inner_html = ''
		case @@mode
			when :game
				@node['data-action-type'] = 'movement'
				@node['data-action-vars'] = "x:#{@x},y:#{@y},z:#{@z}"
				if @@developer_mode
					@node['data-dev-action-type'] = 'dev_tile'
					@node['data-dev-action-vars'] = "x:#{@x},y:#{@y},z:#{@z}"
					@node['oncontextmenu'] = 'return false;'
				else
					@node['oncontextmenu'] = 'return true';
					@node['data-dev-action-type'] = nil
					@node['data-dev-action-vars'] = nil
				end

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
			when :editor
				@node['data-dev-action-type'] = 'dev_tile'
				@node['data-dev-action-vars'] = "x:#{@x},y:#{@y},z:#{@z}"
				@node['oncontextmenu'] = 'return false;'
		end
	end
end
