Given(/(\S+) is affected by extremely powerful regeneration/) do |char_name|
	character = @characters[char_name]
	regeneration = Entity::Status.new
	regeneration.effects << Effect::Regen.new(regeneration, 'ap', :hp, character.hp_max * 2)
	regeneration.stateful = character
end
Given(/(\S+) is affected by a (\d+) HP per (\S+) tick regeneration/) do |char_name, amount, interval|
	character = @characters[char_name]
	regeneration = Entity::Status.new
	regeneration.effects << Effect::Regen.new(regeneration, interval.to_s, :hp, amount.to_i)
	regeneration.stateful = character
end
Given(/(\S+) is affected by a (\d+) HP per (\S+) tick poison/) do |char_name, amount, interval|
	character = @characters[char_name]
	regeneration = Entity::Status.new
	regeneration.effects << Effect::Regen.new(regeneration, interval.to_s, :hp, 0 - amount.to_i)
	regeneration.stateful = character
end