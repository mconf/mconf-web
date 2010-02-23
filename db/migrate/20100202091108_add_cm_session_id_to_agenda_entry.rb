class AddCmSessionIdToAgendaEntry < ActiveRecord::Migration
  def self.up
    add_column :agenda_entries, :cm_session_id, :integer
  end

  def self.down
    remove_column :agenda_entries, :cm_session_id
  end
end
