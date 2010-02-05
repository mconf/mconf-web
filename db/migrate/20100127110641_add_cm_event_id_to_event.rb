class AddCmEventIdToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :cm_event_id, :integer
  end

  def self.down
    remove_column :events, :cm_event_id
  end
end
