class ChangeResourceMachine < ActiveRecord::Migration
  def self.up
    remove_column "event_participants", "resource_id"
    remove_column "event_participants", "resource_id_connected_to"
    add_column "event_participants", "machine_id", :integer
      add_column "event_participants", "machine_id_connected_to", :integer
  end

  def self.down
    add_column "event_participants", "resource_id", :integer
    add_column "event_participants", "resource_id_connected_to", :integer
    remove_column "event_participants", "machine_id"
      remove_column "event_participants", "machine_id_connected_to"
  end
end
