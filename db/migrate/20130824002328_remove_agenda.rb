class RemoveAgenda < ActiveRecord::Migration
  def up
    drop_table :agenda_dividers
    drop_table :agenda_entries
    drop_table :agenda_record_entries
    drop_table :agendas
    remove_column :attachments, :agenda_entry_id
  end

  def down
    throw ActiveRecord::IrreversibleMigration
  end
end
