class OpenidServer < ActiveRecord::Migration
  def self.up
    create_table :open_id_trusts do |t|
      t.integer :agent_id
      t.string  :agent_type
      t.integer :uri_id
      t.boolean :local, :default => false
    end

    add_column :sites, :ssl, :boolean, :default => false
  end

  def self.down
    drop_table :open_id_trusts
    remove_column :sites, :ssl
  end
end
