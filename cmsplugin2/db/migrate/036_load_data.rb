require 'active_record/fixtures'

class LoadData < ActiveRecord::Migration
  def self.up
    directory = File.join(File.dirname(__FILE__), "data")
    Fixtures.create_fixtures(directory, "users")
    Fixtures.create_fixtures(directory, "cms_roles")
    Fixtures.create_fixtures(directory, "spaces")
  end

  def self.down
    User.find_by_login("admin").destroy
    CMS::Role.delete_all
    if Space.find_by_id(0)
      Space.find_by_id(0).destroy
    end
  end
  
end