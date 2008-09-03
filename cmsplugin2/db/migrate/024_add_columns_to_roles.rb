class AddColumnsToRoles < ActiveRecord::Migration
  def self.up
    add_column "cms_roles", "manage_events", :boolean
    add_column "cms_roles", "admin", :boolean
  end

  def self.down
    remove_column "cms_roles", "manage_events"
    remove_column "cms_roles", "admin"
  end
end
