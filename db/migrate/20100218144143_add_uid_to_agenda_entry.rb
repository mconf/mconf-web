class AddUidToAgendaEntry < ActiveRecord::Migration
  def self.up
    add_column :agenda_entries, :uid, :text
  end

  def self.down
    remove_column :agenda_entries, :uid
  end
end
