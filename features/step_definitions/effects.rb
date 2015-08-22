Given(/(\S+) is affected by extremely powerful regeneration/) do |char_name|
	character = @characters[char_name]
	regeneration = Entity::Status.new
	regeneration.effects << Effect::Regen.new(regeneration, 'ap', :hp, character.hp_max * 2)
	regeneration.stateful = character
end