class RenameMwebEventsTables < ActiveRecord::Migration
  def self.up
    rename_table :mweb_events_events, :events
    rename_table :mweb_events_participants, :participants
  end

  def self.down
    rename_table :events, :mweb_events
    rename_table :participants, :mweb_events_participants
  end
end
