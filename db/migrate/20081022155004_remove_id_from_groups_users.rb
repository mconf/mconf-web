class RemoveIdFromGroupsUsers < ActiveRecord::Migration
  def self.up
    remove_column :groups_users, :id
  end

  def self.down
    add_column :groups_users, :id, :primary_key => true
    end
end
