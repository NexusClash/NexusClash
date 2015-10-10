Given(/(\S+) is affected by extremely powerful regeneration/) do |char_name|
	character = @characters[char_name]

	status_type = Entity::StatusType.new
	status_type.impacts = [Effect::Regen.new(status_type, 'ap', :hp, character.hp_max * 2).save_state]
	status_type.save

	character.statuses << Entity::Status.source_from(status_type.id)
end
Given(/(\S+) is affected by a (\d+) HP per (\S+) tick regeneration/) do |char_name, amount, interval|
	character = @characters[char_name]
	regeneration = Entity::Status.new
	regeneration.effects << Effect::Regen.new(regeneration, interval.to_s, :hp, amount.to_i)
	character.statuses << regeneration
end
Given(/(\S+) is affected by a (\d+) HP per (\S+) tick poison/) do |char_name, amount, interval|
	character = @characters[char_name]
	regeneration = Entity::Status.new
	regeneration.effects << Effect::Regen.new(regeneration, interval.to_s, :hp, 0 - amount.to_i)
	character.statuses << regeneration
end

Given(/(\S+) has an innate (\S+) attack \((\d+) (\S+) @ (\d+)%\)/) do |char_name, family, amount, type, hit_chance|
	character = @characters[char_name]
	weapon = Entity::Status.new
	weapon.effects << Effect::Weapon.new(weapon, family.to_sym, hit_chance.to_i, type.to_sym, amount.to_i, 'Test weapon')
	character.statuses << weapon
end

Given(/(\S+) has an item with a (\S+) attack \((\d+) (\S+) @ (\d+)%\)/) do |char_name, family, amount, type, hit_chance|
	character = @characters[char_name]

	status_type = Entity::StatusType.new
	status_type.impacts = [Effect::Weapon.new(status_type, family.to_sym, hit_chance.to_i, type.to_sym, amount.to_i, 'Test weapon').save_state]
	status_type.save

	i_type = Entity::ItemType.new
	i_type.statuses = [status_type.id]
	i_type.save

	character.items << Entity::Item.source_from(i_type.id)
end

Given(/(\S+) has an innate ammo-using (\S+) attack \((\d+) (\S+) @ (\d+)%\) loaded with (\d+) ammo/) do |char_name, family, amount, type, hit_chance, ammo|
	character = @characters[char_name]
	character.set_tag :ammo, ammo.to_i

	status_type = Entity::StatusType.new
	status_type.impacts = [Effect::WeaponWithAmmo.new(status_type, family.to_sym, hit_chance.to_i, type.to_sym, amount.to_i, 1, 'Out of ammo!', 'Test weapon').save_state, Effect::Reloadable.new(status_type, 'test_ammo', 10).save_state]
	status_type.save

	character.statuses << Entity::Status.source_from(status_type.id)
end

Given(/(\S+) has an item with an ammo-using (\S+) attack \((\d+) (\S+) @ (\d+)%\) loaded with (\d+) ammo/) do |char_name, family, amount, type, hit_chance, ammo|
	character = @characters[char_name]
	character.set_tag :ammo, ammo.to_i

	status_type = Entity::StatusType.new
	status_type.impacts = [Effect::WeaponWithAmmo.new(status_type, family.to_sym, hit_chance.to_i, type.to_sym, amount.to_i, 1, 'Out of ammo!', 'Test weapon').save_state, Effect::Reloadable.new(status_type, 'test_ammo', 10).save_state]
	status_type.save

	i_type = Entity::ItemType.new
	i_type.statuses = [status_type.id]
	i_type.save

	character.items << Entity::Item.source_from(i_type.id)
end
Given(/(\S+) has (\d+) ammo/) do |char_name, amount|
	character = @characters[char_name]

	status_type = Entity::StatusType.new
	status_type.impacts = [Effect::Ammo.new(status_type, 'test_ammo', amount.to_i).save_state]
	status_type.save

	i_type = Entity::ItemType.new
	i_type.statuses = [status_type.id]
	i_type.save

	character.items << Entity::Item.source_from(i_type.id)
end

Given(/(\S+) has a skill that increases hit % of (\S+) weapons by (\d+)%/) do |char_name, family, amount|
	character = @characters[char_name]
	buff = Entity::Status.new
	buff.effects << Effect::WeaponBuff.new(buff, family.to_sym, amount.to_i)
	#buff.stateful = character
	character.statuses << buff
end

When(/(\S+) attacks (\S+) with their weapon/) do |char_name, defender_name|
	attacker = @characters[char_name]
	defender = @characters[defender_name]
	weapon = attacker.weaponry.keys[0]
	attacker.attack(defender, weapon)
end

When(/(\S+) reloads their weapon/) do |char_name|
	char = @characters[char_name]
	char.activated_uses.each do |k, v|
		char.use_item_self char.items[0], k
	end
end

When(/(\S+) uses their item/) do |char_name|
	char = @characters[char_name]
	char.activated_uses.each do |k, v|
		char.use_item_self char.items[0], k
		break
	end
end

Given(/(\S+) has a book/) do |char_name|
	character = @characters[char_name]

	status_type = Entity::StatusType.new
	status_type.impacts = [Effect::Activated.new(status_type, {ap: 1}, 'Read').save_state,  Effect::LimitedUses.new(status_type, 1).save_state, Effect::Regen.new(status_type, :item_activation, :xp, 10).save_state, Effect::SendMessage.new(status_type, :item_activation, 'As you read this book you learn how overpowered they are as a levelling method. Gazooks! You have learnt nothing from this book, but gained [xp] XP anyway', BroadcastScope::SELF).save_state]
	status_type.save

	i_type = Entity::ItemType.new
	i_type.statuses = [status_type.id]
	i_type.save

	character.items << Entity::Item.source_from(i_type.id)
end

Given(/(\S+) has a healing potion/) do |char_name|
	character = @characters[char_name]

	status_type = Entity::StatusType.new
	status_type.impacts = [Effect::Activated.new(status_type, {ap: 1}, 'Drink').save_state,  Effect::LimitedUses.new(status_type, 1).save_state, Effect::Regen.new(status_type, :item_activation, :hp, 30).save_state, Effect::SendMessage.new(status_type, :item_activation, 'You quaff the potion. As you do so, you feel its magic flow through you, mending flesh and bone. You regain [hp] HP.', BroadcastScope::SELF).save_state]
	status_type.save

	i_type = Entity::ItemType.new
	i_type.statuses = [status_type.id]
	i_type.save

	character.items << Entity::Item.source_from(i_type.id)
end

Then(/(\S+) should have (\d+) items/) do |char_name, items|
	character = @characters[char_name]
	assert character.items.count == items.to_i, "#{character.name} has #{character.items.count.to_s} items, should have #{items}!"
end