class AddColumnsToRoles2 < ActiveRecord::Migration
  def self.up
    add_column "cms_roles", "is_group", :boolean
    
  end

  def self.down
    remove_column "cms_roles", "is_group"
    
  end
end
