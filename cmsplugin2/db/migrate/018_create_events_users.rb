class CreateEventsUsers < ActiveRecord::Migration
  def self.up
    create_table :events_users, :id=> false do |t|
      t.column :user_id, :integer, :null=>false
      t.column :event_id, :integer, :null=>false
    end
    drop_table :users_events
  end

  def self.down
    drop_table :events_users
    create_table :users_events do |t|
       t.column :user_id, :integer, :null=>false
      t.column :event_id, :integer, :null=>false
    end
  end
end
