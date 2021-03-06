module Entity
	class Tile
		def portals_packets
			game = Firmament::Plane.fetch Instance.plane

			list = []

			dest_z = nil
			direction = nil

			case self.z
				when 0
					dest_z = 1
					direction = 'Inside'
				when 1
					dest_z = 0
					direction = 'Outside'
			end

			if dest_z != nil && game.map?(self.x, self.y, dest_z)
				list << {name: "Step #{direction} #{self.name}", destination: {type: 'movement', x: self.x, y: self.y, z: dest_z}}
			end

			self.portals.each do |portal|
				list << {name: portal.label, destination: {type: 'portal', id: portal.object_id}}
			end

			[{type: 'portals', action: 'replace', portals: list}]
		end
	end
end