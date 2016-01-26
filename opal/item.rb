require 'opal'
require 'browser'
require 'browser/socket'
require 'browser/console'
require 'browser/dom'
require 'browser/dom/document'
require 'browser/http'
require 'browser/delay'
require 'native'

puts 'Loading Item...'

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
