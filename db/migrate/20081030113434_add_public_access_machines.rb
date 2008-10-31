class AddPublicAccessMachines < ActiveRecord::Migration
  def self.up
    add_column :machines, :public_access, :boolean, :default=>false
  end

  def self.down
   remove_column :spaces, :public_access
  end
end
