class AddStreamingAndRecordingToAgendaEntries < ActiveRecord::Migration
  def self.up
    add_column :agenda_entries, :cm_streaming, :boolean, :default => false
    add_column :agenda_entries, :cm_recording, :boolean, :default => false
  end

  def self.down
    remove_column :agenda_entries, :cm_streaming
    remove_column :agenda_entries, :cm_recording
  end
end
