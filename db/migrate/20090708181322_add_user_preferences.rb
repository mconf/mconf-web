class AddUserPreferences < ActiveRecord::Migration
  def self.up
    add_column :users, :expanded_post, :boolean, :default=> false
    add_column :users, :notification, :integer, :default=> 1
  end

  def self.down
    remove_column :users, :expanded_post
    remove_column :users, :notification
  end
end
