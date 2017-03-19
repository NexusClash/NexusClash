unless ENV['RACK_ENV'] == 'production'
  namespace :character do
    desc "Kills every character"
    task :kill_them_all => :environment do
    	Firmament::Plane.new Instance.plane
    	Entity::Character.all.each do |character|
    		character.kill!
    		character.x = VoidTile::DEAD_COORDINATE
    		character.y = VoidTile::DEAD_COORDINATE
    		character.z = VoidTile::DEAD_COORDINATE
    		character.plane = Instance.plane
    		character.save
    	end
    end

    desc "Grant all applicable skills to the specified character"
    task :deify, [:char_id] => :environment do |t, args|
      character = Entity::Character.find(args.char_id.to_i)

      all_skills = Entity::StatusType.where({family: :skill})

      all_skills.each do |skill_type|
        status = Entity::Status.source_from(skill_type.id)
        character.statuses << status
      end

      character.save
    end

    desc "Grant a specific skill to the specified character"
    task :grant, [:char_id, :type_id] => :environment do |t, args|
      character = Entity::Character.find(args.char_id.to_i)

      status = Entity::Status.source_from(args.type_id.to_i)
      character.statuses << status

      character.save
    end

    desc "Grant one of each applicable item to the specified character"
    task :endow, [:char_id] => :environment do |t, args|
      character = Entity::Character.find(args.char_id.to_i)

      all_items = Entity::ItemType.all

      all_items.each do |item_type|
        item = Entity::Item.source_from(item_type.id)
        character.items << item
      end

      status_type = Entity::StatusType.find_by({:name => 'Super Strength'})
      status = Entity::Status.source_from(status_type.id)
      character.statuses << status

      character.save
    end

    desc "Grant one specific item to the specified character"
    task :give, [:char_id, :type_id] => :environment do |t, args|
      character = Entity::Character.find(args.char_id.to_i)

      item = Entity::Item.source_from(args.type_id.to_i)
      character.items << item

      character.save
    end
  end
end
