class CreateSpaces < ActiveRecord::Migration
  def self.up
    create_table :spaces do |t|
      t.string  :name
      t.string  :description
      t.integer :parent_id
      t.boolean :deleted
    end

  end

  def self.down
    drop_table :spaces
  end
end