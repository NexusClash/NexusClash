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
	attr_accessor :id, :name, :hp, :hp_fuzzy, :hp_max, :mp, :mp_max, :xp, :level, :mo, :cp, :nexus_class, :sense_hp, :sense_mo, :sense_mp, :alignment
	attr_accessor :x, :y, :z
	attr_accessor :neighbours, :map, :me, :ap, :target, :statuses, :abilities

	def type
		'character'
	end

	def initialize(data, me = false)
		if me
			@map = Magellan.new $document.at_css('#map')
			@neighbours = Hash.new{|hash, charid| hash[charid] = Adventurer.new({id: charid})}
		end
		@abilities = Array.new
		@statuses = Array.new
		@me = me
		@id = data['id']
		@target = nil
		update data
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

	def mp_fuzzy
		return 'full' if mp >= mp_max
		return 'high' if mp > mp_max * 0.5
		return 'mid' if mp > mp_max * 0.25
		return 'low'
	end

	def update(data)
		self.name = data['name'] if data.has_key? 'name'
		self.hp = data['hp'] if data.has_key? 'hp'
		self.hp_fuzzy = data['hp_fuzzy'] if data.has_key? 'hp_fuzzy'
		self.hp_max = data['hp_max'] if data.has_key? 'hp_max'
		self.mp = data['mp'] if data.has_key? 'mp'
		self.mp_max = data['mp_max'] if data.has_key? 'mp_max'
		self.xp = data['xp'] if data.has_key? 'xp'
		self.level = data['level'] if data.has_key? 'level'
		self.mo = data['mo'] if data.has_key? 'mo'
		self.cp = data['cp'] if data.has_key? 'cp'
		self.x = data['x'] if data.has_key? 'x'
		self.y = data['y'] if data.has_key? 'y'
		self.z = data['z'] if data.has_key? 'z'
		self.ap = data['ap'] if data.has_key? 'ap'
		self.sense_hp = data['sense_hp'] if data.has_key? 'sense_hp'
		self.sense_mo = data['sense_mo'] if data.has_key? 'sense_mo'
		self.sense_mp = data['sense_mp'] if data.has_key? 'sense_mp'
		self.alignment = data['alignment'] if data.has_key? 'alignment'
		self.nexus_class = data['nexus_class'] if data.has_key? 'nexus_class'
		self.statuses = data['visible_statuses'] if data.has_key? 'visible_statuses'
		self.abilities = data['abilities'] if data.has_key? 'abilities'
		render
	end

	def render
		if @me
			$document.at_css('#hud_player_vitals .ap').inner_html = @ap
			$document.at_css('#hud_player_vitals .mp').inner_html = @mp
			$document.at_css('#hud_player_vitals .cp').inner_html = @cp
			$document.at_css('#hud_player_vitals .ui-hud-cp')['data-player-cp'] = @cp
			$document.at_css('#hud_player_vitals .mo').inner_html = sprintf '%.1f' ,@mo / 10
			$document.at_css('#hud_player_vitals .xp').inner_html = @xp
			$document.at_css('#hud_player_vitals .hp').inner_html = @hp
			$document.at_css('#hud_player_vitals .level').inner_html = @level
			$document.at_css('#hud_player_vitals .class').inner_html = @nexus_class
			$document.at_css('#hud_player_vitals .name').inner_html = "<a href='/character/#{@id}' style='color:black;text-decoration:none'>#{@name}</a>"

			status_text = ''
			self.statuses.each do |status|
				status_text += "<li title='#{status[:description]}'>#{status[:name]}</li>"
			end
			$document.at_css('#hud_player_vitals .statuses').inner_html = status_text
			occupants = ''
			@neighbours.keys.each do |key|
				neighbour = @neighbours[key]
				mp_widget = ''
				mo_widget = ''
				mp_widget = "<span class='mp-widget' data-state='#{neighbour.mp_fuzzy}' title='#{neighbour.mp}/#{neighbour.mp_max}'></span>" if sense_mp
				mo_widget = "<span class='mo-widget' data-state='#{neighbour.alignment}' title='#{neighbour.alignment}'></span>" if sense_mo
				occupants += "<li><span data-char-link='#{neighbour.id}'>#{neighbour.name}</span> (#{neighbour.level})<span class='hp-widget' data-state='#{neighbour.hp_fuzzy}' #{sense_hp ? "title='#{neighbour.hp}/#{neighbour.hp_max}'" : ''}></span>#{mp_widget}#{mo_widget}</li>"
			end
			$document.at_css('#tile_occupants_players').inner_html = occupants
			ability_ul = $document.at_css('#abilities')
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
				$document.at_css('#target_information .name').inner_html = ''
				$document.at_css('#target_information .class_image').attributes['src'] = ''
				$document.at_css('#target_information .stats').inner_html = ''
				$document.at_css('#target_information .actions').inner_html = ''
			else
				$document.at_css('#target_information .name').inner_html = "<a href='/character/#{@target.id}' style='color:black;text-decoration:none'>#{@target.name}</a>"
				$document.at_css('#target_information .class_image').attributes['src'] = "/img/class/colour/#{@target.nexus_class}.png"
				stats = "<li>Level #{target.level} #{@target.nexus_class}</li><li>HP: #{sense_hp ? "#{@target.hp} / #{@target.hp_max}" : @target.hp_fuzzy}</li>"
				stats = stats + "<li>MP: #{@target.mp} / #{@target.mp_max}</li>" if sense_mp
				stats = stats + "<li>Alignment: #{@target.alignment}</li>" if sense_mo
				$document.at_css('#target_information .stats').inner_html = stats
				$document.at_css('#target_information .actions').inner_html = '' unless @neighbours.has_key? @target.id
			end
			if @hp <= 0 || (@x == -9001 && @y == -9001 && @z == -9001)
				$document.at_css('#details_pane_alive').attributes[:class] = 'ui-helper-hidden'
				$document.at_css('#details_pane_dead').attributes[:class] = ''
			else
				$document.at_css('#details_pane_alive').attributes[:class] = ''
				$document.at_css('#details_pane_dead').attributes[:class] = 'ui-helper-hidden'
			end
		end
	end
end
