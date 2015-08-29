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

Given(/(\S+) has an innate (\S+) attack \((\d+) (\S+) @ (\d+)%\)/) do |char_name, family, amount, type, hit_chance|
	character = @characters[char_name]
	weapon = Entity::Status.new
	weapon.effects << Effect::Weapon.new(weapon, family.to_sym, hit_chance.to_i, type.to_sym, amount.to_i, 'Test weapon')
	weapon.stateful = character
end

Given(/(\S+) has an innate ammo-using (\S+) attack \((\d+) (\S+) @ (\d+)%\) loaded with (\d+) ammo/) do |char_name, family, amount, type, hit_chance, ammo|
	character = @characters[char_name]
	character.set_tag :ammo, ammo.to_i
	weapon = Entity::Status.new
	weapon.effects << Effect::WeaponWithAmmo.new(weapon, family.to_sym, hit_chance.to_i, type.to_sym, amount.to_i, 1, 'Out of ammo!', 'Test weapon')
	weapon.effects << Effect::Reloadable.new(weapon, 'test_ammo', 10)
	weapon.stateful = character
end

When(/(\S+) attacks (\S+)/) do |char_name, defender_name|
	attacker = @characters[char_name]
	defender = @characters[defender_name]
	weapon = attacker.weaponry.keys[0]
	attacker.attack(defender, weapon)
end