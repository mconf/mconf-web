class AddNotesFieldInEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :notes, :text
  end

  def self.down
    remove_column :events, :notes
  end
end
