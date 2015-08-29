Given(/a character named (\S+)/) do |name|
	@characters = Hash.new if @characters === nil
	character = Entity::Character.new
	character.name = name
	@characters[name] = character
end

Given(/(\S+) is badly wounded/) do |char_name|
	character = @characters[char_name]
	max = character.hp_max - 5
	character.hp = rand(2...max)
end

Given(/(\S+) has (\d+) HP/) do |char_name, hp|
	character = @characters[char_name]
	character.hp = hp.to_i
end

Given(/(\S+) has (\d+) AP/) do |char_name, ap|
	character = @characters[char_name]
	character.ap = ap.to_i
end

Then(/(\S+) should be at full HP/) do |char_name|
	character = @characters[char_name]
	character.hp == character.hp_max
end

Then(/(\S+) should have (\d+) HP/) do |char_name, hp|
	character = @characters[char_name]
	character.hp == hp.to_i
end

Then(/(\S+) should have (\d+) AP/) do |char_name, ap|
	character = @characters[char_name]
	character.ap == ap.to_i
end