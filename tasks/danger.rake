unless ENV['RACK_ENV'] == 'production'
  namespace :danger do
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
  end
end
