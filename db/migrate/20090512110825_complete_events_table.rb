class CompleteEventsTable < ActiveRecord::Migration
  def self.up
    add_column :events, :marte_event, :boolean, :default => false
    add_column :events, :marte_room, :boolean, :default => nil 
  end

  def self.down
    remove_column :events, :marte_event
    remove_column :events, :marte_room
  end
end
