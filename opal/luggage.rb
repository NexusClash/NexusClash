require 'opal'
require 'browser'
require 'browser/socket'
require 'browser/console'
require 'browser/dom'
require 'browser/dom/document'
require 'browser/http'
require 'browser/delay'
require 'native'

require 'item'

puts 'Loading Luggage...'

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
				@nodes[item.category].parent.parent.remove
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
