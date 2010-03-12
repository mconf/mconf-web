require File.dirname(__FILE__) + '/rails_commands'
class StationGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      #TODO: check for collisions

      m.directory 'public/images/models'
      m.directory 'public/images/models/16'
      m.directory 'public/images/models/96'
      m.file 'public/images/models/16/site.png', 'public/images/models/16/site.png'
      m.file 'public/images/models/96/site.png', 'public/images/models/96/site.png'

      m.file 'public/stylesheets/style.css', 'public/stylesheets/style.css'
      m.file 'public/stylesheets/screen.css', 'public/stylesheets/screen.css'
      m.file 'public/stylesheets/print.css', 'public/stylesheets/print.css'
      m.file 'public/stylesheets/ie.css', 'public/stylesheets/ie.css'

      m.file 'public/403.html', 'public/403.html'
      m.route_root
      m.migration_template 'migration.rb',
                           'db/migrate',
                           :migration_file_name => "station_migration"
    end
  end
end
