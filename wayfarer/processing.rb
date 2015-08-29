module Wayfarer


	def self.process_message(ws, json)


		case json['type'].to_s
			when 'refresh_map'
				ws.send({packets: ws.character.location_packets}.to_json)
			when 'movement'
				nx = json['x'].to_i
				ny = json['y'].to_i
				nz = json['z'].to_i
				game = Firmament::Plane.fetch Instance.plane
				ws.character.move game.map nx, ny, nz
				#packets = surrounds_packet(ws.character)
				#ws.send({packets: packets}.to_json)
			when 'target'
				game = Firmament::Plane.fetch Instance.plane
				target = game.character(json['char_id'])
				ws.target = target
				weaps_hash = Hash.new
				weaps = ws.character.weaponry
				weaps.keys.each do |weapi|
					weaps_hash[weapi] = weaps[weapi].to_hash
				end
				packets = [{type: 'actions', actions:{attacks: weaps_hash}}]
				ws.send({packets: packets}.to_json)
			when 'speech'
				message = json['message']
				unless message.strip.empty? || message.strip == '/me'
					targets = Array.new
					ws.character.location.characters.each do |char|
						targets << char.id
					end
					if message.start_with? '/me'
						message = "#{ws.character.name_link}#{Rack::Utils.escape_html(message[3..-1])}"
						msg_type = MessageType::SPEECH_EMOTE
					else
						message = "#{ws.character.name_link} said \"#{Rack::Utils.escape_html(message)}\""
						msg_type = MessageType::SPEECH
					end
					message_ent = Entity::Message.new({characters: targets, message: message, type: msg_type})
					message_ent.save
				end
			when 'sync_messages'
				packets = Array.new

				if json['from'] === nil
					messages = Entity::Message.character(ws.character.id).desc('_id').limit(20)
				else
					messages = Entity::Message.character_from(ws.character.id, Time::at(json['from'].to_i).utc).desc('_id').limit(20)
				end
				messages.each do |msg|
					packets << msg.to_packet
				end
				packets.reverse!
				ws.send({packets: packets}.to_json) if packets.count > 0
			when 'attack'
				case json['target_type']
					when 'character'
						game = Firmament::Plane.fetch Instance.plane
						target = game.character(json['target'].to_i)
					else
						return
				end
				ws.character.attack target, json['weapon'].to_i
			when 'respawn'
				ws.character.respawn if ws.character.dead?
			when 'request_skill_tree'
				root = Array.new

				nodes_added = 0

				ws.character.statuses.each do |status|
					if status.family == :class
						nodes_added += 1
						root << {id: status.link, name: status.name, type: :class, learned: true, children: []}
					end
				end

				add_to_tree = lambda do |tree, item, prereq; pinpoint, found, children, found2|
					pinpoint = tree.index{|esrc| esrc[:id] == prereq}
					found = false
					if pinpoint === nil
						tree.map! { |ele|
							children, found2 = add_to_tree.call(ele[:children], item, prereq)
							ele[:children] = children if found2
							found = found || found2
							ele
						}
					else
						tree[pinpoint][:children] << item
						found = true
					end
					return tree, found
				end

				skips = []

				ws.character.statuses.each do |instance_skill|
					if instance_skill.family == :skill
						instance_skill.effects.each do |effect|
							if effect.is_a?(Effect::SkillPrerequisite)
								tree, node_add = add_to_tree.call(root, {id: instance_skill.link, name: instance_skill.name, description: instance_skill.describe, type: instance_skill.family, learned: true, cost: 0, children: []}, effect.link.id)
								root = tree if node_add
								skips << instance_skill.link
							end
						end
					end
				end

				Entity::StatusType.skills.each do |skill|
					if skill.family == :skill
						instance_skill = Entity::Status.source_from(skill.id)
						instance_skill.effects.each do |effect|
							if effect.is_a?(Effect::SkillPrerequisite) && !skips.include?(skill.id)

								cp_cost = 0

								instance_skill.effects.each do |seffect|
									cp_cost += seffect.cp_cost if seffect.is_a?(Effect::SkillPurchasable)
								end

								tree, node_add = add_to_tree.call(root, {id: skill.id, name: instance_skill.name, description: instance_skill.describe, type: instance_skill.family, learned: false, cost: cp_cost, children: []}, effect.link.id)
								root = tree if node_add

							end
						end
					end
				end
				root = [root] unless root.is_a? Array
				ws.send({packets: [{type: 'skill_tree', tree: root }]}.to_json)
			when 'learn_skill'

				skill = Entity::StatusType.find json['id']

				if skill.family == :skill

					nskill = Entity::Status.source_from json['id']

					cp_cost = 0
					has_reqs = true

					nskill.effects.each do |effect|

						cp_cost += effect.cp_cost if effect.is_a?(Effect::SkillPurchasable)

						if effect.is_a?(Effect::SkillPrerequisite)
							check = ws.character.statuses.index{|e| e.link == effect.link.id}
							has_reqs = false if check === nil
						end

					end

					if has_reqs && cp_cost <= ws.character.cp
						ws.character.cp -= cp_cost
						nskill.stateful = ws.character
						ws.character.broadcast_self BroadcastScope::SELF
						message_ent = Entity::Message.new({characters: [ws.character.id], message: "You have learnt #{nskill.name}.", type: MessageType::SKILL_LEARNT})
						message_ent.save
						process_message(ws, {'type' => 'request_skill_tree'})
					else
						Entity::Message.send_transient([ws.character.id], 'You cannot learn this skill at this time!', MessageType::FAILED)
					end


				end
			when 'search'
				if ws.character.ap < 1	|| ws.character.location.is_a?(VoidTile)
					Entity::Message.send_transient([ws.character.id], 'You cannot search at this time!', MessageType::FAILED)
					return
				end

				ws.character.ap -= 1

				item_drop = nil
				item_drop = ws.character.location.type.search_roll_item if ws.character.location.type.search_roll

				if item_drop === nil
					message_ent = Entity::Message.new({characters: [ws.character.id], message: 'You search and find nothing.', type: MessageType::SEARCH_NOTHING})
					message_ent.save
				else
					message_ent = Entity::Message.new({characters: [ws.character.id], message: "You search and find #{item_drop.a_or_an} #{item_drop.name}.", type: MessageType::SEARCH_SUCCESS})
					message_ent.save
					item_drop.carrier = ws.character

					packet = {packets:[{type: 'inventory', weight: ws.character.weight, weight_max: ws.character.weight_max, list: 'add', items: [item_drop.to_h]}]}

					ws.send(packet.to_json)
				end

				ws.character.broadcast_self BroadcastScope::SELF
			when 'drop'
				id = json['id'].to_i

				ws.character.items.each do |item_drop|
					if item_drop.object_id == id
						message_drop = Entity::Message.new({characters: [ws.character.id], message: "You drop your #{item_drop.name}.", type: MessageType::ITEM_DROP})
						message_drop.save
						ws.send({packets:[{type: 'inventory', weight: ws.character.weight, weight_max: ws.character.weight_max, list: 'remove', items: [item_drop.object_id]}]}.to_json)
						ws.character.remove_item item_drop
						return
					end
				end
			when 'dev_tile'
				if ws.character.account.has_role?(:admin) || ws.character.has_nexus_class?(:Developer)
					game = Firmament::Plane.fetch Instance.plane
					tile = game.map(json['x'], json['y'], json['z'])

					if(json.has_key?('edit'))
						if tile.is_a?(VoidTile) && json['type_id'].to_i != -1
							tile = Entity::Tile.new
							tile.plane = Instance.plane
							tile.x = json['x'].to_i
							tile.y = json['y'].to_i
							tile.z = json['z'].to_i
							tile.type_id = json['type_id'].to_i
							tile.name = json['name']
							tile.description = json['description']
							tile.save
							game.remove_void(tile.x, tile.y, tile.z)
						else
							tile.plane = Instance.plane
							tile.x = json['x'].to_i
							tile.y = json['y'].to_i
							tile.z = json['z'].to_i
							tile.type_id = json['type_id'].to_i
							tile.name = json['name']
							tile.description = json['description']
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

					end

					types = Hash.new

					types[-1] = '(Void)'

					Entity::TileType.each do |type|
						types[type.id] = type.name
					end

					ws.send({packets:[{type:'dev_tile', types: types, tile: tile.to_h}]}.to_json)
				end
			when 'refresh_inventory'

				items = []

				ws.character.items.each do |item|
					items << item.to_h
				end

				packet = {packets:[{type: 'inventory', weight: ws.character.weight, weight_max: ws.character.weight_max, list: 'clear', items: items}]}

				ws.send(packet.to_json)

			when 'activate_item_self'
				item = nil
				ws.character.items.each do |e_item|
					if e_item.object_id == json['id'].to_i
						item = e_item
					end
				end
				if item === nil
					Entity::Message.send_transient([ws.character.id],'Unable to find specified item!', MessageType::FAILED)
				else
					ws.character.use_item_self item, json['status_id'].to_i
				end

		end


	end

end