unless ENV['RACK_ENV'] == 'production'
  namespace :db do
    desc 'Resets the database to its initial seeded state'
    task :bounce => ['db:wipe', 'db:seed', 'db:fixtures']

    desc 'Deletes all the things from the db'
    task :wipe => :environment do
      Entity.constants.select{|c| Entity.const_get(c).is_a? Class}.each do |klass_sym|
        klass = Entity.class_eval(klass_sym.to_s)
        next unless klass.respond_to?(:destroy_all)
        puts "Wiping #{klass_sym}... "
        count = klass.destroy_all
        puts " Done. (removed #{count} records)"
      end
      puts
    end
  end
end
