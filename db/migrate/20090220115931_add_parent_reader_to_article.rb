class AddParentReaderToArticle < ActiveRecord::Migration
  def self.up
    add_column :articles, :reader_id, :integer
  end

  def self.down
    remove_column :articles, :reader_id
  end
end
