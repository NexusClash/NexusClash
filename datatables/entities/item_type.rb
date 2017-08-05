module Entity
	class ItemType
		def to_datatable
			description = self.statuses.map {|s|
				t = Entity::StatusType.find(s)
		    "<b>#{t.name}</b><br/>#{t.describe("<br/>")}"
			}

			{name: self.name, category: self.category, weight: self.weight, id: self.id, game_effects: description.join("\n") }
		end

		def from_datatable(row)
			self.name = row[:name]
			self.category = row[:category].to_sym
			self.weight = row[:weight].to_i
		end

	end
end