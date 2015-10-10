Given(/a tile at (\d+), ?(\d+), ?(\d+)/) do |x, y, z|
	plane = Firmament::Plane.fetch Instance.plane
	tile = Entity::Tile.new
	tile.plane = Instance.plane
	tile.x = x.to_i
	tile.y = y.to_i
	tile.z = z.to_i
	tile.save
	plane.remove_void(tile.x, tile.y, tile.z)
end

Given(/(\S+) is at (\d+), ?(\d+), ?(\d+)/) do |char_name, x, y, z|
	plane = Firmament::Plane.fetch Instance.plane
	character = @characters[char_name]
	character.location = plane.map(x, y, z)
end

When(/(\S+) attempts to move to (\d+), ?(\d+), ?(\d+)/) do |char_name, x, y, z|
	plane = Firmament::Plane.fetch Instance.plane
	character = @characters[char_name]
	character.move plane.map(x, y, z)
end

Then(/(\S+) should be at (\d+), ?(\d+), ?(\d+)/) do |char_name, x, y, z|
	plane = Firmament::Plane.fetch Instance.plane
	character = @characters[char_name]
	assert character.location == plane.map(x, y ,z), "#{character.name} isn't at #{x}, #{y}, #{z}!"
end

Then(/(\d+), ?(\d+), ?(\d+) should have (\d+) occupants/) do |x, y, z, occupants|
	plane = Firmament::Plane.fetch Instance.plane
	assert plane.map(x, y, z).characters.count == occupants.to_i, "#{x}, #{y}, #{z} has #{plane.map(x, y, z).characters.count.to_s} occupants, should be #{occupants}!"
end

Then(/(\S+) should be next to (\d+) people/) do |char_name, occupants|
	character = @characters[char_name]
	assert character.location.characters.count == occupants.to_i + 1, "#{character.name} is next to #{(character.location.characters.count - 1).to_s} people, should be #{occupants}!"
end