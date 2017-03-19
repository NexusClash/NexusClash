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
      puts "Gave #{character.name} all the skills."
    end

    desc "Grant a specific skill to the specified character"
    task :grant, [:char_id, :type_id] => :environment do |t, args|
      character = Entity::Character.find(args.char_id.to_i)

      status = Entity::Status.source_from(args.type_id.to_i)
      character.statuses << status

      character.save
      puts "Granted #{character.name} the status #{status.name}."
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
      puts "Gave #{character.name} one of each item type (and super strength)."
    end

    desc "Grant one specific item to the specified character"
    task :give, [:char_id, :type_id] => :environment do |t, args|
      character = Entity::Character.find(args.char_id.to_i)

      item = Entity::Item.source_from(args.type_id.to_i)
      character.items << item

      character.save
      puts "Gave #{character.name} one #{item.name}."
    end

    desc "Make a character moral"
    task :moralize, [:char_id] => :environment do |t, args|
      character = Entity::Character.find(args.char_id.to_i)
      character.mo = 400
      character.save
      puts "Made #{character.name} a paragon of virtue."
    end

    desc "Make a character immoral"
    task :immoralize, [:char_id] => :environment do |t, args|
      character = Entity::Character.find(args.char_id.to_i)
      character.mo = -400
      character.save
      puts "Made #{character.name} a traitorous wretch."
    end

    desc "Assign a class to a character"
    task :classify, [:char_id, :classname] => :environment do |t, args|
      character = Entity::Character.find(args.char_id.to_i)
      type = Entity::StatusType.find_by({:family => :class, :name => args.classname})
      status = Entity::Status.source_from(type.id)
      character.statuses << status
      character.save
      puts "Granted #{character.name} the #{args.classname} class."
    end

    desc "Assign all base-level skills from the (applicable) skill tree to a character"
    task :skillize, [:char_id] => :environment do |t, args|
      character = Entity::Character.find(args.char_id.to_i)

      class_names = character.nexus_classes.map {|s| s.name}
      class_types = character.nexus_classes.map {|s| s.type.id}

      # TODO: instead use the skill_tree(true) on character and loop over that tree
      added_skills = 0
      skills = Entity::StatusType.where({:family => 'skill'})
      skills.each do |skill|
        skill.impacts.each do |impact|
          if impact[0] == "SkillPrerequisite" and class_types.include?(impact[1])
            status = Entity::Status.source_from(skill.id)
            character.statuses << status
            added_skills += 1
          end
        end
      end

      character.save

      puts "Granted #{character.name} #{added_skills} skills from #{class_names.join(', ')} classes."
    end
  end
end
