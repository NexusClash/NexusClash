require 'set'
module Entity
	class Character
		include Behaviour::Movable
		include Behaviour::Aggressor
		include Behaviour::Usable
		include Behaviour::Crafter
		include Pronouns
		include Behaviour::Activator

		def broadcast(scope, packet)
			case scope
				when BroadcastScope::SELF
					@socket.send(packet) unless @socket === nil
				when BroadcastScope::TARGET
					self.location.characters.each do |char|
						char.socket.send(packet) unless char.socket === nil || char.socket.target != self
					end
				when BroadcastScope::TILE
					self.location.characters.each do |char|
						char.socket.send(packet) unless char.socket === nil || !self.visible_to?(char)
					end
				when BroadcastScope::VISIBLE
					game = Firmament::Plane.fetch Instance.plane
					tiles = Set.new
					(-2..2).each do |y|
						(-2..2).each do |x|
							tiles.add game.map(self.location.x + x, self.location.y + y, self.location.z)
						end
					end

					tiles.each do |tile|
						tile.characters.each do |char|
							char.socket.send(packet) unless char.socket === nil || !self.visible_to?(char)
						end
					end

			end
		end

		def broadcast_self(scope = BroadcastScope::NONE)
			packet = {packets: [{type: 'character', character: self.to_hash(scope)}]}.to_json #TODO: Base detail on the broadcast scope
			broadcast scope, packet
			broadcast_self(BroadcastScope::SELF) if scope > BroadcastScope::SELF
		end

		def xp=(new_xp)
			self[:xp] = new_xp
			self.level_up! while new_xp >= self.level_xp_required?(self.level + 1)
		end

		def level_up!
			self.level = self.level + 1
			if self.level > 1
				cp_bonus = ((self.level / 10).floor + 1) * 10
				self.cp += cp_bonus
				msg_lvlup = "You have levelled up! You are now level #{self.level}! You have gained #{cp_bonus} Character Points. Your new total is #{self.cp} CP."
				msg_lvlup << "As you have reached level #{self.level}, you may now select a tier #{(self.level / 10).floor + 1} class!" if self.level == 10 || self.level == 20
				msg_lvlup << " You are #{self.level_xp_required?(self.level + 1) - self.xp} XP away from gaining another level." if self.level < 30
				msg = Entity::Message.new({characters: [self.id], type: MessageType::LEVEL_SELF, message: msg_lvlup})
				self.broadcast_self BroadcastScope::SELF
				msg.save
				occs = []
				self.location.characters.each do |char|
					occs << char.id unless char === self
				end
				if occs.length > 0
					msg_area = Entity::Message.new({characters: occs, type: MessageType::LEVEL_OTHER, message: "#{self.name_link} has levelled up!"})
					msg_area.save
				end
				self.broadcast_self BroadcastScope::TILE
			end
		end

		def level_xp_required?(target_level)
			xp_counter = 0
			(1..target_level).each do |lev|
				mult = ((lev - 1) / 3).floor + 1
				xp_counter += mult * 100 unless lev == 1
			end
			return xp_counter
		end

		def hp=(new_hp)
			self[:hp] = new_hp
			if new_hp <= 0
				kill!
			end
		end

		# Morality hooking for Alonai's Aegis

		def mo_hook=(val)
			@mo_hook = val
		end

		def mo_hook
			@mo_hook
		end

		def mo=(val)
			if @mo_hook === nil
				val = mo_max if val > mo_max
				val = mo_min if val < mo_min
				self[:mo] = val
			else
				self[:mo] = @mo_hook.mo=(val)
			end
		end

		def mo
			if @mo_hook === nil
				self[:mo]
			else
				@mo_hook.mo
			end

		end

		def kill!(tick = true)
			self[:hp] = 0 if self.hp > 0
			Entity::Status.tick(self, StatusTick::DEATH) if tick
			self[:hp] = 0 if self.hp > 0
			game = Firmament::Plane.fetch Instance.plane
			move! game.map(VoidTile::DEAD_COORDINATE, VoidTile::DEAD_COORDINATE, VoidTile::DEAD_COORDINATE)
		end

		def respawn
			cost = ((self.level - 1) / 3).floor + 1
			if self.ap >= 1
				self.ap -= cost
				self.hp = self.hp_max
				self.visibility = Visibility::VISIBLE
				game = Firmament::Plane.fetch Instance.plane
				if Instance.plane == 3
					move! game.map(rand(12...15),rand(10...16),0)
				else
					move! game.map(1,1,0)
				end
				msg = Entity::Message.new({characters: [self.id], type: MessageType::SPAWN_SELF, message: 'Your spirit feels drawn to a new body and you quickly enter it. You have respawned.'})
				msg.save
			end
		end

		def location_packets

			game = Firmament::Plane.fetch Instance.plane

			packets = [{type: 'character', character: self.to_hash(BroadcastScope::SELF)}]

			if self.z == 0
				(-2..2).each do |y|
					(-2..2).each do |x|
						tile = game.map(self.x + x, self.y + y, self.z)
						packets << { type: 'tile', tile: tile.to_h}
					end
				end
			else
				(-2..2).each do |y|
					(-2..2).each do |x|
						if x == 0 && y == 0
							tile = game.map(self.x + x, self.y + y, self.z)
							packets << { type: 'tile', tile: tile.to_h}
						else
							packets << {type: 'tile', tile: VoidTile.generate_hash(self.x + x, self.y + y, self.z)}
						end
					end
				end
			end

			packets.concat(@location.portals_packets)

			@location.characters.each do |char|
				packets << {type: 'character', character: char.to_hash(BroadcastScope::TILE) } unless char === self || !char.visible_to?(self)
			end

			packets
		end

		def location
			@location || VoidTile.new(Instance.plane, VoidTile::DEAD_COORDINATE, VoidTile::DEAD_COORDINATE, VoidTile::DEAD_COORDINATE)
		end

		def location=(loc)
			if @location === nil
				@location = loc
				return
			end
			unless @location === loc
				@location.characters.delete(self)
				loc.characters << self
				oldloc = @location
				@location = loc
				self.x = @location.x
				self.y = @location.y
				self.z = @location.z
				self.socket.send({packets: self.location_packets}.to_json) unless self.socket === nil
				update_location oldloc, loc if self.respond_to? :update_location
			end
		end

		def update_location(old, new)

			game = Firmament::Plane.fetch Instance.plane

			rmpacket = {packets:[type:'remove_character', char_id: self.id]}.to_json
			old.characters.each do |char|
				char.socket.send(rmpacket) unless char == self || char.socket === nil || !self.visible_to?(char)
			end


			packets = Array.new

			packets << { type: 'tile', tile:{ x: old.x, y: old.y, z: old.z, occupants: old.visible_character_count}}
			packets << { type: 'tile', tile:{ x: new.x, y: new.y, z: new.z, occupants: new.visible_character_count}}

			packet = {packets: packets}.to_json
			tiles = Set.new


			(-2..2).each do |y|
				(-2..2).each do |x|
					tiles.add game.map(old.x + x, old.y + y, old.z) unless old.z != 0 && (x != 0 || y != 0)
					tiles.add game.map(new.x + x, new.y + y, new.z) unless new.z != 0 && (x != 0 || y != 0)
				end
			end

			tiles.each do |tile|
				tile.characters.each do |char|
					char.socket.send(packet) unless char == self || char.socket === nil || !self.visible_to?(char)
				end
			end

		end

		def remove_item(item)
			self.remove_child item
			@weight -= item.weight if @weight
			self.shard.pending_deletion << item
		end

		def each_applicable_effect(&block)
			self.each_applicable_status do |status|
				status.effects.each(&block)
			end
		end

		def each_applicable_status(&block)
			self.statuses.each(&block)
			self.items.each do |item|
				item.statuses.each(&block)
				item.type_statuses.each(&block)
			end
			self.location.statuses.each(&block)
			self.location.type_statuses.each(&block)
		end

		def skill_tree(all = false)
			root = Array.new

			nodes_added = 0

			statuses.each do |status|
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

			statuses.each do |instance_skill|
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

			if all
				unassigned = Array.new

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

								unless node_add
									unassigned << [{id: skill.id, name: instance_skill.name, description: instance_skill.describe, type: instance_skill.family, learned: false, cost: cp_cost, children: []}, effect.link.id]
								end

							end
						end
					end
				end

				old_quantity = 0
				while old_quantity != unassigned.count do
					old_quantity = unassigned.count
					unassigned.each do |element|

						tree, node_add = add_to_tree.call(root, element[0], element[1])
						root = tree if node_add

						unassigned.delete(element) if node_add
					end
				end
			end





			root = [root] unless root.is_a? Array
			return root
		end

	end
end
