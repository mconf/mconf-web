class CreateReaders < ActiveRecord::Migration
  def self.up
    create_table :readers do |t|
      t.string :url
      t.integer :space_id
      t.datetime :last_updated
      t.timestamps
    end
  end

  def self.down
    drop_table :readers
  end
end
