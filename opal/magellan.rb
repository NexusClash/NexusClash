require 'opal'
require 'browser'
require 'browser/socket'
require 'browser/console'
require 'browser/dom'
require 'browser/dom/document'
require 'browser/http'
require 'browser/delay'
require 'native'

require 'tile'

puts 'Loading Magellan...'

class Magellan

	attr_accessor :binding
	attr_reader :radius
	attr_accessor :surrounds

	def initialize(binding, radius = 2)
		@binding = binding
		@radius = radius
		@surrounds = Hash.new{|hash, key| hash[key] = Hash.new}

		(-@radius..@radius).each do |y|
			(-@radius..@radius).each do |x|
				@surrounds[x][y] = Tile.new @binding
				@surrounds[x][y].origin_tile = x == 0 && y == 0
				@surrounds[x][y].clear_left = true if x == -@radius
			end
		end

		render
	end

	def render
		(-@radius..@radius).each do |y|
			(-@radius..@radius).each do |x|
				@surrounds[x][y].render
			end
		end
	end
end