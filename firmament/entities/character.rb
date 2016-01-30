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
						char.socket.send(packet) unless char.socket === nil
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
							char.socket.send(packet) unless char.socket === nil
						end
					end

			end
		end

		def broadcast_self(scope = BroadcastScope::NONE)
			packet = {packets: [{type: 'character', character: self.to_hash}]}.to_json #TODO: Base detail on the broadcast scope
			broadcast scope, packet
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

		def kill!
			self[:hp] = 0 if self.hp > 0
			game = Firmament::Plane.fetch Instance.plane
			move! game.map(VoidTile::DEAD_COORDINATE, VoidTile::DEAD_COORDINATE, VoidTile::DEAD_COORDINATE)
		end

		def respawn
			cost = ((self.level - 1) / 3).floor + 1
			if self.ap >= cost
				self.ap -= cost
				self.hp = self.hp_max
				game = Firmament::Plane.fetch Instance.plane
				move! game.map(1,1,0)
				msg = Entity::Message.new({characters: [self.id], type: MessageType::SPAWN_SELF, message: 'Your spirit feels drawn to a new body and you quickly enter it. You have respawned.'})
				msg.save
			end
		end

		def location_packets

			game = Firmament::Plane.fetch Instance.plane

			packets = [{type: 'character', character: self.to_hash}]

			if self.z == 0
				(-2..2).each do |y|
					(-2..2).each do |x|
						tile = game.map(self.x + x, self.y + y, self.z)
						packets << { type: 'tile', tile:{ x: tile.x, y: tile.y, z: tile.z, name: tile.name, description: tile.description, colour: tile.colour, type: tile.type.name, occupants: tile.characters.count}}
					end
				end
			else
				(-2..2).each do |y|
					(-2..2).each do |x|
						if x == 0 && y == 0
							tile = game.map(self.x + x, self.y + y, self.z)
							packets << { type: 'tile', tile:{ x: tile.x, y: tile.y, z: tile.z, name: tile.name, description: tile.description, colour: tile.colour, type: tile.type.name, occupants: tile.characters.count}}
						else
							packets << {type: 'tile', tile: VoidTile.generate_hash(self.x + x, self.y + y, self.z)}
						end
					end
				end
			end

			packets.concat(@location.portals_packets)

			@location.characters.each do |char|
				packets << {type: 'character', character: char.to_hash } unless char === self
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
				char.socket.send(rmpacket) unless char == self || char.socket === nil
			end


			packets = Array.new

			packets << { type: 'tile', tile:{ x: old.x, y: old.y, z: old.z, occupants: old.characters.count}}
			packets << { type: 'tile', tile:{ x: new.x, y: new.y, z: new.z, occupants: new.characters.count}}

			packet = {packets: packets}.to_json
			tiles = Set.new


			(-2..2).each do |y|
				(-2..2).each do |x|
					tiles.add game.map(old.x + x, old.y + y, old.z)
					tiles.add game.map(new.x + x, new.y + y, new.z)
				end
			end

			tiles.each do |tile|
				tile.characters.each do |char|
					char.socket.send(packet) unless char == self || char.socket === nil
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

	end
end