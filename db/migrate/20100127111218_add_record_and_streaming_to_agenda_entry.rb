class AddRecordAndStreamingToAgendaEntry < ActiveRecord::Migration
  def self.up
    add_column :agenda_entries, :streaming, :boolean, :defaul => false
    add_column :agenda_entries, :recording, :boolean, :defaul => false
  end

  def self.down
    remove_column :agenda_entries, :streaming
    remove_column :agenda_entries, :recording
  end
end
