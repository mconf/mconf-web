class RemoveNotificationsFromUsers < ActiveRecord::Migration
  def up
  	remove_column :users, :notifications 
  end

  def down
  	add_column :users, :notifications
  end
end
