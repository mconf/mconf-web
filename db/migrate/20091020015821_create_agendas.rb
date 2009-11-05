class CreateAgendas < ActiveRecord::Migration
  def self.up
    create_table :agendas do |t|
      t.integer :event_id
      t.timestamps
    end
    
    create_table :agenda_entries do |t|
      t.integer :agenda_id
      t.string :title
      t.text :description
      t.string :speakers
      t.datetime :start_time
      t.datetime :end_time
      t.boolean :record
      t.timestamps
    end
    
    create_table :agenda_record_entries do |t|
      t.integer :agenda_id
      t.string :title
      t.datetime :start_time
      t.datetime :end_time
      t.boolean :record
      t.timestamps
    end
    
    add_column :attachments, :agenda_entry_id, :integer
  end

  def self.down
    drop_table :agendas
    drop_table :agenda_record_entries
    drop_table :agenda_entries
    
    remove_column :attachments, :agenda_entry_id
  end
end
