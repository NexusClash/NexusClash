Given(/a character named (\S+)/) do |name|
	if @characters === nil
		@characters = Hash.new
		Mongoid.purge! if Mongoid.default_session.options[:database] == :nexusdash_test # Lets be EXTRA SAFE
		Entity::StatusType.purge_cache
		Entity::TileType.purge_cache
	end
	character = Entity::Character.new
	character.name = name
	character.save
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

Given(/(\S+) has (\d+) XP/) do |char_name, xp|
	character = @characters[char_name]
	character.xp = xp.to_i
end

Then(/(\S+) should be at full HP/) do |char_name|
	character = @characters[char_name]
	assert character.hp == character.hp_max, "#{character.name} has #{character.hp.to_s} HP, should have #{character.hp_max.to_s}!"
end

Then(/(\S+) should have (\d+) HP/) do |char_name, hp|
	character = @characters[char_name]
	assert character.hp == hp.to_i, "#{character.name} has #{character.hp.to_s} HP, should have #{hp}!"
end

Then(/(\S+) should have (\d+) AP/) do |char_name, ap|
	character = @characters[char_name]
	assert character.ap == ap.to_i, "#{character.name} has #{character.ap.to_s} AP, should have #{ap}!"
end

Then(/(\S+) should have (\d+) XP/) do |char_name, xp|
	character = @characters[char_name]
	assert	character.xp == xp.to_i, "#{character.name} has #{character.xp.to_s} XP, should have #{xp}!"
end