class AddDividerToAgendaEntry < ActiveRecord::Migration
  def self.up
    add_column :agenda_entries, :divider, :text
  end

  def self.down
    remove_column :agenda_entries, :divider
  end
end
