class AdminDisabledAdded < ActiveRecord::Migration
  def self.up
    add_column :users, :superuser , :boolean, :default => false
    add_column :users, :disabled , :boolean, :default => false
  end
 
  def self.down
    remove_column :users, :superuser
    remove_column :users, :disabled
  end
end
