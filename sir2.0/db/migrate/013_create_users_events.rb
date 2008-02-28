class CreateUsersEvents < ActiveRecord::Migration
  def self.up
    create_table :users_events do |t|
      t.column :user_id, :integer, :null=>false
      t.column :event_id, :integer, :null=>false
    end
  end

  def self.down
    drop_table :users_events
  end
end
