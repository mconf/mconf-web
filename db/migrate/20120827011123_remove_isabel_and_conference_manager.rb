class RemoveIsabelAndConferenceManager < ActiveRecord::Migration
  def up
    remove_column :events, :isabel_event
    remove_column :events, :isabel_interface
    remove_column :events, :isabel_bw
    remove_column :events, :cm_event_id
    remove_column :agenda_entries, :cm_session_id
    remove_column :agenda_entries, :cm_streaming
    remove_column :agenda_entries, :cm_recording
    remove_column :sites, :cm_domain
  end

  def down
    throw ActiveRecord::IrreversibleMigration
  end
end
