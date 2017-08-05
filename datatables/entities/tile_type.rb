module Entity
	class TileType
		def to_datatable
			description = self.statuses.map {|s|
				t = Entity::StatusType.find(s)
				"<b>#{t.name}</b><br/>#{t.describe("<br/>")}"
			}

			{name: self.name, description: self.description, colour: self.colour, id: self.id, search_rate: self.search_rate, hide_rate: self.hide_rate, css: self.css, game_effects: description.join("\n")}
		end

		def from_datatable(row)
			self.name = row[:name]
			self.search_rate = row[:search_rate].to_i
			self.hide_rate = row[:hide_rate].to_i
			self.description = row[:description]
			self.css = row[:css]
		end
	end
end