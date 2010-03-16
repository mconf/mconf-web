class AddAgendaDivider < ActiveRecord::Migration
  def self.up
    create_table :agenda_dividers do |t|
      t.integer :agenda_id
      t.string :title
      t.datetime :start_time
      t.timestamps
    end
  end

  def self.down
    drop_table :agenda_dividers
  end
end
