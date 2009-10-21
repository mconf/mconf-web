class SourceImportationUri < ActiveRecord::Migration
  def self.up
    add_column :source_importations, :uri_id, :integer
  end

  def self.down
    remove_column :source_importations, :uri_id
  end
end
