class RmRecordFromAgendaEntries < ActiveRecord::Migration
  def self.up
    remove_column :agenda_entries, :record
  end

  def self.down
    add_column :agenda_entries, :record, :boolean
  end
end
