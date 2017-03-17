module Entity
	class Message
		after_create do |document|
			game = Firmament::Plane.fetch Instance.plane
			json = {packets: [document.to_packet]}.to_json
			document.characters.each do |char|
				if game.character? char
					character = game.character char
					character.socket.send(json) unless character.socket === nil
				end
			end
		end

		def to_packet
			{type:'message',class: self.type, message: self.message, timestamp: self.timestamp.utc.to_i}
		end

		def self.send_transient(target_ids, message, type = :transient)
			game = Firmament::Plane.fetch Instance.plane
			json = {packets: [{type:'message',class: type, message: message, timestamp: Time.now.utc.to_i}]}.to_json
			target_ids.each do |char_id|
				if game.character? char_id
					character = game.character char_id
					character.socket.send(json) unless character.socket === nil
				end
			end
		end
	end
end
