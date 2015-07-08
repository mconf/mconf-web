# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class TestMigrator

  def self.previous_version(target_version)
    all_versions = ActiveRecord::Migrator.get_all_versions
    # if not found assumes we're testing the latest migration
    all_versions.include?(target_version) ? current_idx = all_versions.index(target_version) : current_idx = all_versions.count-1
    previous = current_idx == 0 ? all_versions[0] : all_versions[current_idx-1]
  end

  def self.migrate(target_version)
    ActiveRecord::Migrator.migrate(ActiveRecord::Migrator.migrations_path, target_version)
  end

  def self.up
    ActiveRecord::Migrator.up(ActiveRecord::Migrator.migrations_path)
  end

  def self.load_data
    system("bundle exec rake db:data:load RAILS_ENV=test")
  end

  def self.migrate_to_previous(target_version)
    previous = TestMigrator.previous_version(target_version)
    TestMigrator.migrate(previous)
  end

  def self.load_data_and_migrate(target_version)
    TestMigrator.up
    previous = TestMigrator.previous_version(target_version)

    # rollback, load data then migrate
    puts "* Migrating to #{previous}"
    TestMigrator.migrate(previous)
    puts "* Loading db/data.yml"
    TestMigrator.load_data
    puts "* Migrating to #{target_version}"
    TestMigrator.migrate(target_version)

    if ActiveRecord::Migrator.current_version != target_version
      puts "It wasn't possible to migrate to the selected migration version"
      puts "* Current version: #{ActiveRecord::Migrator.current_version}"
      puts "* Desired version: #{target_version}"
      puts "You probably need to run:"
      puts "* rake db:migrate RAILS_ENV=test"
      exit 1
    end
  end

end
