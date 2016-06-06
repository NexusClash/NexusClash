module Wayfarer
	module Engine

		attr_reader :user
		attr_reader :character
		attr_accessor :identifier
		attr_accessor :target

		#Used by admin non-game connections
		attr_accessor :admin

		#Used by server connections
		attr_accessor :plane

		def character=(val)
			@icd = Time.now.to_f * 1000
			@character = val
			@user = val.account
		end

		def throttle(method, json = {}, icd = 0)
			return false if icd == 0
			now = Time.now.to_f  * 1000
			if now - icd >= @icd
				# Can perform action
				@icd += icd
				@icd = now + icd if @icd <= now
				return false
			else
				# Throttle
				w = (@icd - (now - icd)).to_f.abs / 1000
				w = icd if w > icd
				Entity::Message.send_transient([character.id], "Queueing #{method} for ~#{w * 1000}ms due to input throttle...", MessageType::DEBUG)
				sleep w
				return false
			end
		end


		def game
			@game ||= Firmament::Plane.fetch Instance.plane
		end

		def self.api_functions
			@@api_functions ||= Set.new Wayfarer::Engine.instance_methods(false).select{|method| (method.to_s.end_with?('=') || [:user, :character, :identifier, :target, :admin, :plane, :game].include?(method)) ? false : true}
		end

		def request_character(_)
			send({packets: [{type: 'character', character: character.to_hash}]}.to_json)
		end

		def refresh_map(_)
			send({packets: @character.location_packets}.to_json)
		end

		def movement(json)
			character.move game.map json['x'].to_i, json['y'].to_i, json['z'].to_i
		end

		def portal(json)
			return if throttle :portal, json
			found = nil

			character.location.portals.each do |portal|
				found = portal if portal.object_id.to_s == json['id']
			end

			if found === nil
				Entity::Message.send_transient([character.id], 'Unable to find that portal here!', MessageType::FAILED)
			else

				if found.plane == game.plane.id
					character.move! game.map found.x, found.y, found.z
					message = found.use_text
					msg_type = MessageType::PORTAL_USE
					message_ent = Entity::Message.new({characters: [character.id], message: message, type: msg_type})
					message_ent.save
				else
					#Generate auth token
					token = SecureRandom.hex
					Entity::Account.where(username: user.username).update(authentication_token: token)

					# Unload character

					character.save
					Entity::Character.where(id: character.id).update(x: found.x, y: found.y, z: found.z, plane: found.plane)
					game.unload_character! character.id

					message = found.use_text
					msg_type = MessageType::PORTAL_USE
					message_ent = Entity::Message.new({characters: [character.id], message: message, type: msg_type})
					message_ent.save

					plane = Entity::Plane.where({plane: found.plane}).first

					send({packets: [{type: 'warp', url: "https://#{plane.domain}/warp/#{user.username}/#{character.id}/#{token}/game" }]}.to_json)

					rmpacket = {packets:[type:'remove_character', char_id: character.id]}.to_json

					old = character.location

					old.characters.each do |char|
						char.socket.send(rmpacket) unless char == self || char.socket === nil
					end

					rmpacket = { type: 'tile', tile:{ x: old.x, y: old.y, z: old.z, occupants: old.characters.count}}

					packet = {packets: rmpacket}.to_json
					tiles = Set.new

					(-2..2).each do |y|
						(-2..2).each do |x|
							tiles.add game.map(old.x + x, old.y + y, old.z)
						end
					end

					tiles.each do |tile|
						tile.characters.each do |char|
							char.socket.send(packet) unless char == self || char.socket === nil
						end
					end

				end
			end
		end

		def select_target(json, include = {attacks: true, abilities: true, charge_attacks: true})
			self.target = game.character(json['char_id']) if json.has_key? 'char_id'
			output = {}
			if include[:attacks]
				weaps_hash = Hash.new
				weaps = character.weaponry
				weaps.keys.each do |weapi|
					weaps_hash[weapi] = weaps[weapi].to_hash
				end
				output[:attacks] = weaps_hash
			end
			if include[:abilities]
				abilities = character.activated_uses_target @target
				abilities_hash = Hash.new
				abilities.keys.each do |ability_i|
					ability = abilities[ability_i]
					abilities_hash[ability_i] = {name: ability.name}
				end
				output[:abilities] = abilities_hash
			end
			if include[:charge_attacks]
				charge_attacks = character.charge_attacks
				charge_attacks_hash = Hash.new
				charge_attacks.each do |charge_attack|
					charge_attacks_hash[charge_attack.object_id] = {name: charge_attack.name, description: charge_attack.describe}
				end
				output[:charge_attacks] = charge_attacks_hash
			end

			packets = [{type: 'actions', actions: output}]
			send({packets: packets}.to_json)
		end

		def speech(json)
			message = json['message']
			unless message === nil || message.strip.empty? || message.strip == '/me'
				targets = Array.new
				character.location.characters.each do |char|
					targets << char.id
				end
				if message.start_with? '/me'
					message = "#{character.name_link}#{Rack::Utils.escape_html(message[3..-1])}"
					msg_type = MessageType::SPEECH_EMOTE
				else
					message = "#{character.name_link} said \"#{Rack::Utils.escape_html(message)}\""
					msg_type = MessageType::SPEECH
				end
				message_ent = Entity::Message.new({characters: targets, message: message, type: msg_type})
				message_ent.save
			end
		end

		def sync_messages(json)
			packets = Array.new

			if json['from'] === nil
				messages = Entity::Message.character(character.id).desc('_id').limit(20)
			else
				messages = Entity::Message.character_from(character.id, Time::at(json['from'].to_i).utc).desc('_id').limit(20)
			end
			messages.each do |msg|
				packets << msg.to_packet
			end
			packets.reverse!
			send({packets: packets}.to_json) if packets.count > 0
		end

		def attack(json)
			return if throttle :attack, json, 300
			case json['target_type']
				when 'character'
					character.attack game.character(json['target'].to_i), json['weapon'].to_i, (json.has_key?('charge_attack') && json['charge_attack'] != '' ? json['charge_attack'].to_i : nil)
			end
		end

		def respawn(_)
			character.respawn if character.dead? || character.location.type == Entity::VoidTileType
		end

		def request_skill_tree(*_)

			send({packets: [{type: 'skill_tree', tree: character.skill_tree(true) }]}.to_json)
		end


		def request_classes(_)
			classes = Array.new

			Entity::StatusType.classes.each do |nex_class|

				if nex_class.family == :class

					nex_class_i = Entity::Status.source_from nex_class.id

					if Intent::Learn.new(character, nex_class_i).possible?
						tier = 0

						attributes = Array.new
						nex_class_i.effects.each do |eff|
							attributes << eff.describe if eff.is_a? Effect::CustomText
							tier = eff.tier if eff.respond_to? :tier
						end
						classes << {name: nex_class.name, attributes: attributes, tier: tier, id: nex_class.id}
					end

				end
				send({packets: [{type: 'class_choices', classes: classes }]}.to_json)
			end
		end

		def learn_skill(json)
			return if throttle :learn_skill, json
			skill = Entity::StatusType.find json['id']
			learn = Intent::Learn.new character, skill
			if learn.realise
				request_skill_tree
			else
				Entity::Message.send_transient([character.id], 'You cannot learn this skill at this time!', MessageType::FAILED)
			end
		end

		def search(_)
			return if throttle :search
			if character.ap < 1	|| character.location.is_a?(VoidTile)
				Entity::Message.send_transient([character.id], 'You cannot search at this time!', MessageType::FAILED)
				return
			end

			character.ap -= 1

			item_drop = nil
			item_drop = character.location.type.search_roll_item if character.location.type.search_roll

			if item_drop === nil
				message_ent = Entity::Message.new({characters: [character.id], message: 'You search and find nothing.', type: MessageType::SEARCH_NOTHING})
				message_ent.save
			else
				message_ent = Entity::Message.new({characters: [character.id], message: "You search and find #{item_drop.a_or_an} #{item_drop.name}.", type: MessageType::SEARCH_SUCCESS})
				message_ent.save
				item_drop.carrier = character

				packet = {packets:[{type: 'inventory', weight: character.weight, weight_max: character.weight_max, list: 'add', items: [item_drop.to_h]}]}

				send(packet.to_json)
			end

			if rand(1..100) < 25

				character.location.characters.each do |char|
					if !char.visible_to?(character) && char.visibility == Visibility::HIDING
						char.reveal_to! character
						message_ent = Entity::Message.new({characters: [character.id], message: "You find #{char.name_link} while searching. #{char.pronoun(:he)} is hiding.", type: MessageType::SEARCH_SUCCESS})
						message_ent.save
						break
					end
				end

			end


			character.broadcast_self BroadcastScope::SELF
		end

		def hide(_)
			return if throttle :hide
			if character.ap < 1	|| character.location.is_a?(VoidTile)
				Entity::Message.send_transient([character.id], 'You cannot hide at this time!', MessageType::FAILED)
				return
			end

			if character.visibility > Visibility::VISIBLE
				Entity::Message.send_transient([character.id], 'You don\'t need to hide, because you already aren\'t visible to casual bystanders!', MessageType::FAILED)
				return
			end

			character.ap -= 1

			if rand(1..100) < character.location.type.hide_rate
				message_ent = Entity::Message.new({characters: [character.id], message: 'You are now hidden.', type: MessageType::HIDDEN})
				message_ent.save

				# Hide character
				character.visibility = character.visibility | Visibility::HIDING

			else
				message_ent = Entity::Message.new({characters: [character.id], message: 'You look around but have trouble finding anywhere to hide.', type: MessageType::FAILED})
				message_ent.save
				if character.location.type.hide_rate == 0
					message_ent = Entity::Message.new({characters: [character.id], message: 'There appears to be absolutely no hope of hiding here at all - You should try somewhere else...', type: MessageType::FAILED})
					message_ent.save
				end
			end

			character.broadcast_self BroadcastScope::SELF
		end

		def drop(json)
			id = json['id'].to_i

			character.items.each do |item|
				if item.object_id == id
					message_drop = Entity::Message.new({characters: [character.id], message: "You drop your #{item.name}.", type: MessageType::ITEM_DROP})
					message_drop.save
					character.remove_item item
					send({packets:[{type: 'inventory', weight: character.weight, weight_max: character.weight_max, list: 'remove', items: [item.object_id]}]}.to_json)
					return
				end
			end
		end

		def dev_tile(json)
			if admin || user.has_role?(:admin) || character.has_nexus_class?(:Developer)

				tile = game.map(json['x'], json['y'], json['z'])

				if json.has_key?('edit')
					if tile.is_a?(VoidTile) && json['type_id'].to_i != -1
						tile = Entity::Tile.new
						tile.plane = Instance.plane
						tile.x = json['x'].to_i
						tile.y = json['y'].to_i
						tile.z = json['z'].to_i
						tile.type_id = json['type_id'].to_i if json.has_key? 'type_id'
						tile.name = json['name'] if json.has_key? 'name'
						tile.description = Rack::Utils.unescape(Wayfarer.json_unescape(json['description'])) if json.has_key? 'description'
						tile.save
						game.remove_void(tile.x, tile.y, tile.z)
					else
						tile.plane = Instance.plane
						tile.x = json['x'].to_i
						tile.y = json['y'].to_i
						tile.z = json['z'].to_i
						tile.type_id = json['type_id'].to_i if json.has_key? 'type_id'
						tile.name = json['name'] if json.has_key? 'name'
						tile.description = Rack::Utils.unescape(Wayfarer.json_unescape(json['description'])) if json.has_key? 'description'
						tile.save
					end

					packet = {packets:[{ type: 'tile', tile:{ x: tile.x, y: tile.y, z: tile.z, name: tile.name, description: tile.description, colour: tile.colour, type: tile.type.name, occupants: tile.characters.count}}]}.to_json

					chars = Array.new

					if(tile.z == 0)
						(-2..2).each do |y|
							(-2..2).each do |x|
								dtile = game.map(tile.x + x, tile.y + y, tile.z)
								dtile.characters.each do |char|
									chars << char unless char.socket === nil
								end
							end
						end
					else
						tile.characters.each do |char|
							chars << char unless char.socket === nil
						end
					end

					chars.each do |char|
						char.socket.send(packet) unless char.socket === nil
					end

					packet = {packets:[{ type: 'tile', tile:{ x: tile.x, y: tile.y, z: tile.z, name: tile.name, description: tile.description, colour: tile.colour, type: tile.type.name, type_id: tile.type.id, occupants: tile.characters.count}}]}.to_json

					Firmament::Plane.admins.each do |admin|
						admin.send(packet)
					end

				end

				types = [[-1, '(Void)']]

				Entity::TileType.each do |type|
					types << [type.id, type.name]
				end

				types.sort! do |a, b|
					a[1] <=> b[1]
				end

				types = Hash[types.map {|key, value| [key, value]}]

				send({packets:[{type:'dev_tile', types: types, tile: tile.to_h}]}.to_json)
			end
		end

		def refresh_inventory(_)
			items = []

			character.items.each do |item|
				items << item.to_h
			end

			packet = {packets:[{type: 'inventory', weight: character.weight, weight_max: character.weight_max, list: 'clear', items: items}]}

			send(packet.to_json)
		end

		def activate_item_self(json)
			return if throttle :activate_item_self, json
			item = nil
			character.items.each do |e_item|
				if e_item.object_id == json['id'].to_i
					item = e_item
				end
			end
			if item === nil
				Entity::Message.send_transient([character.id],'Unable to find specified item!', MessageType::FAILED)
			else
				character.use_item_self item, json['status_id'].to_i
			end
		end

		def activate_self(json)
			return if throttle :activate_self, json
			uses = character.activated_uses
			if uses.has_key? json['status_id'].to_i
				uses[json['status_id'].to_i].realise
			else
				Entity::Message.send_transient([character.id],'Unable to find specified ability!', MessageType::FAILED)
			end
		end

		def activate_target(json)
			return if throttle :activate_target, json
			uses = character.activated_uses_target @target
			if uses.has_key? json['status_id'].to_i
				uses[json['status_id'].to_i].realise
				select_target({}, {attacks: false, abilities: true, charge_attacks: false})
			else

				character.items.each do |item|
					uses = item.activated_uses_target @target
					if uses.has_key? json['status_id'].to_i
						uses[json['status_id'].to_i].realise
						select_target({}, {attacks: false, abilities: true, charge_attacks: false})
						return
					end
				end

				Entity::Message.send_transient([character.id],'Unable to find specified ability!', MessageType::FAILED)
			end
		end

		def request_tile_css(json)
			if json.has_key? 'coordinates'

				coords = json['coordinates']
				tile = game.map coords['x'], coords['y'], coords['z']
				type = tile.type
				send({packets: [{type: 'tile_css', tile: type.name, css: type.css}]}.to_json)

			end
		end

		def admin_map_load(json)
			return unless admin
			sx = json['x'].to_i
			sy = json['y'].to_i
			z = json['z'].to_i
			w = 0
			h = 0
			w = json['w'].to_i - 1 if json.has_key? 'w'
			h = json['h'].to_i - 1 if json.has_key? 'h'
			mx = sx + w
			my = sy + h
			tiles = Array.new
			#styles = Array.new
			(sy..my).each do |y|
				(sx..mx).each do |x|
					tile = game.map x, y, z
					# Loading looks more like loading if we don't send these with the tiles
					#unless styles.include? tile.type.name
					#	type = tile.type
					#	tiles << {type: 'tile_css', tile: type.name, css: type.css}
					#end
					tiles << {type: 'tile', tile: tile.to_h} #unless tile.type.id == -1
					if tiles.count > 24
						send({packets: tiles}.to_json)
						tiles.clear
					end
				end
			end
			send({packets: tiles}.to_json)
		end

		def request_crafting_recipes(_)
			recipes = character.recipes
			recipe_list = []
			recipes.each do |_,recipe|
				recipe_list << recipe.to_h
			end
			send({packets: [{type: 'crafting_recipes', recipes: recipe_list }]}.to_json)
		end

		def craft(json)
			return if throttle :craft, json
			character.craft(json['id'].to_i)
		end
	end
end