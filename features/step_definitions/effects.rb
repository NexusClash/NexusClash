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

Given(/(\S+) has an item with a (\S+) attack \((\d+) (\S+) @ (\d+)%\)/) do |char_name, family, amount, type, hit_chance|
	character = @characters[char_name]
	item = Entity::Item.new
	weapon = Entity::Status.new
	weapon.effects << Effect::Weapon.new(weapon, family.to_sym, hit_chance.to_i, type.to_sym, amount.to_i, 'Test weapon')
	item.type_statuses = [weapon]
	item.carrier = character
end

Given(/(\S+) has an innate ammo-using (\S+) attack \((\d+) (\S+) @ (\d+)%\) loaded with (\d+) ammo/) do |char_name, family, amount, type, hit_chance, ammo|
	character = @characters[char_name]
	character.set_tag :ammo, ammo.to_i
	weapon = Entity::Status.new
	weapon.effects << Effect::WeaponWithAmmo.new(weapon, family.to_sym, hit_chance.to_i, type.to_sym, amount.to_i, 1, 'Out of ammo!', 'Test weapon')
	weapon.effects << Effect::Reloadable.new(weapon, 'test_ammo', 10)
	weapon.stateful = character
end

Given(/(\S+) has an item with an ammo-using (\S+) attack \((\d+) (\S+) @ (\d+)%\) loaded with (\d+) ammo/) do |char_name, family, amount, type, hit_chance, ammo|
	character = @characters[char_name]
	character.set_tag :ammo, ammo.to_i
	item = Entity::Item.new
	weapon = Entity::Status.new
	weapon.effects << Effect::WeaponWithAmmo.new(weapon, family.to_sym, hit_chance.to_i, type.to_sym, amount.to_i, 1, 'Out of ammo!', 'Test weapon')
	weapon.effects << Effect::Reloadable.new(weapon, 'test_ammo', 10)
	item.type_statuses = [weapon]
	item.carrier = character
end

Given(/(\S+) has (\d+) ammo/) do |char_name, amount|
	character = @characters[char_name]
	item = Entity::Item.new
	ammo = Entity::Status.new
	ammo.effects << Effect::Ammo.new(ammo, 'test_ammo', 10)
	item.type_statuses = [ammo]
	item.carrier = character
end

Given(/(\S+) has a skill that increases hit % of (\S+) weapons by (\d+)%/) do |char_name, family, amount|
	character = @characters[char_name]
	buff = Entity::Status.new
	buff.effects << Effect::WeaponBuff.new(buff, family.to_sym, amount.to_i)
	buff.stateful = character
end

When(/(\S+) attacks (\S+) with their weapon/) do |char_name, defender_name|
	attacker = @characters[char_name]
	defender = @characters[defender_name]
	weapon = attacker.weaponry.keys[0]
	attacker.attack(defender, weapon)
end

When(/(\S+) reloads their weapon/) do |char_name|
	char = @characters[char_name]
	use = char.activated_uses[0]
	char.use_item_self char.items[0], use.object_id
end

When(/(\S+) uses their item/) do |char_name|
	char = @characters[char_name]
	use = char.activated_uses[0]
	char.use_item_self char.items[0], use.object_id
end

Given(/(\S+) has a book/) do |char_name|
	character = @characters[char_name]
	item = Entity::Item.new
	book = Entity::Status.new
	book.effects << Effect::Activated.new(book, {ap: 1}, 'Read')
	book.effects << Effect::LimitedUses.new(book, 1)
	book.effects << Effect::Regen.new(book, :item_activation, :xp, 10)
	book.effects << Effect::SendMessage.new(book, :item_activation, 'As you read this book you learn how overpowered they are as a levelling method. Gazooks! You have learnt nothing from this book, but gained [xp] XP anyway', BroadcastScope::SELF)
	item.type_statuses = [book]
	item.carrier = character
end

Given(/(\S+) has a healing potion/) do |char_name|
	character = @characters[char_name]
	item = Entity::Item.new
	potion = Entity::Status.new
	potion.effects << Effect::Activated.new(potion, {ap: 1},'Drink')
	potion.effects << Effect::LimitedUses.new(potion, 1)
	potion.effects << Effect::Regen.new(potion, :item_activation, :hp, 30)
	potion.effects << Effect::SendMessage.new(potion, :item_activation, 'You quaff the potion. As you do so, you feel its magic flow through you, mending flesh and bone. You regain [hp] HP.', BroadcastScope::SELF)
	item.type_statuses = [potion]
	item.carrier = character
end

Then(/(\S+) should have (\d+) items/) do |char_name, items|
	character = @characters[char_name]
	character.items.count == items.to_i
end