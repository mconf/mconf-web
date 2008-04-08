require 'active_record/fixtures'

class LoadData < ActiveRecord::Migration
  def self.up
    directory = File.join(File.dirname(__FILE__), "data")
    Fixtures.create_fixtures(directory, "users")
    Fixtures.create_fixtures(directory, "cms_roles")
  end

  def self.down
    User.find_by_login("admin").destroy
    Role.delete_all
  end
  
end