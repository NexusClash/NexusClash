require 'opal'
require 'browser'
require 'browser/socket'
require 'browser/console'
require 'browser/dom'
require 'browser/dom/document'
require 'browser/http'
require 'browser/delay'
require 'native'

require 'magellan'



class Adventurer
	attr_accessor :id, :name, :hp, :hp_fuzzy, :mp, :xp, :level, :mo, :cp, :nexus_class
	attr_accessor :x, :y, :z
	attr_accessor :neighbours, :map, :me, :ap, :target, :statuses, :abilities

	def type
		'character'
	end

	def initialize(data, me = false)
		if me
			@map = Magellan.new $document['map']
			@neighbours = Hash.new{|hash, charid| hash[charid] = Adventurer.new({id: charid})}
		end
		@abilities = Array.new
		@statuses = Array.new
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
		self.statuses = data['visible_statuses'] if data.has_key? 'visible_statuses'
		self.abilities = data['abilities'] if data.has_key? 'abilities'
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
		self.statuses = data['visible_statuses'] if data.has_key? 'visible_statuses'
		self.abilities = data['abilities'] if data.has_key? 'abilities'
		render
	end

	def render
		if @me
			$document['#hud_player_vitals .ap'].inner_html = @ap
			$document['#hud_player_vitals .mp'].inner_html = @mp
			$document['#hud_player_vitals .cp'].inner_html = @cp
			$document['#hud_player_vitals .ui-hud-cp']['data-player-cp'] = @cp
			$document['#hud_player_vitals .mo'].inner_html = sprintf '%.1f' ,@mo / 10
			$document['#hud_player_vitals .xp'].inner_html = @xp
			$document['#hud_player_vitals .hp'].inner_html = @hp
			$document['#hud_player_vitals .level'].inner_html = @level
			$document['#hud_player_vitals .class'].inner_html = @nexus_class
			$document['#hud_player_vitals .name'].inner_html = "<a href='/character/#{@id}' style='color:black;text-decoration:none'>#{@name}</a>"

			status_text = ''
			self.statuses.each do |status|
				status_text += "<li title='#{status[:description]}'>#{status[:name]}</li>"
			end
			$document['#hud_player_vitals .statuses'].inner_html = status_text
			occupants = ''
			@neighbours.keys.each do |key|
				neighbour = @neighbours[key]
				occupants += "<li><span data-char-link='#{neighbour.id}'>#{neighbour.name}</span> (#{neighbour.level})<span class='hp-widget' data-state='#{neighbour.hp_fuzzy}'></span></li>"
			end
			$document['tile_occupants_players'].inner_html = occupants
			ability_ul = $document['#abilities']
			ability_ul.inner_html = ''

			@abilities.each do |ability|
				next if ability['name'] == ''
				node2 = DOM{
					li
				}
				node = DOM{
					button
				}
				node.inner_html = ability['name']
				node.attributes[:title] = ability['description'] if ability.has_key? 'description'
				node.attributes[:'data-action-type'] = 'activate_self'
				node.attributes[:'data-action-vars'] = "status_id:#{ability['status_id']}"
				node.append_to node2
				node2.append_to ability_ul
			end
			if @target === nil
				$document['#target_information .name'].inner_html = ''
				$document['#target_information .class_image'].attributes['src'] = ''
				$document['#target_information .stats'].inner_html = ''
				$document['#target_information .actions'].inner_html = ''
			else
				$document['#target_information .name'].inner_html = "<a href='/character/#{@target.id}' style='color:black;text-decoration:none'>#{@target.name}</a>"
				$document['#target_information .class_image'].attributes['src'] = "/img/class/colour/#{@target.nexus_class}.png"
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