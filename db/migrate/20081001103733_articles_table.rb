class ArticlesTable < ActiveRecord::Migration
  def self.up
    rename_table 'xhtml_texts', 'articles'
    add_column 'articles', 'title', :string
    remove_column 'articles', 'type'
  end

  def self.down
    add_column 'articles', 'type', :string
    remove_column 'articles', 'title'
    rename_table 'articles', 'xhtml_texts'
  end
end
