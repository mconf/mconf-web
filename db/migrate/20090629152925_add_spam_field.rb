class AddSpamField < ActiveRecord::Migration
  def self.up
    add_column :posts, :spam, :boolean, :default => false
    add_column :events, :spam, :boolean, :default => false
  end

  def self.down
    remove_column :posts, :spam
    remove_column :events, :spam
  end
end
