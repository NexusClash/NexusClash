When(/there is an? (\S+) tick/) do |tick|
	@characters.each do |key, value|
		Entity::Status.tick value, tick
	end
end