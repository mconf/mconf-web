class AddRepositoryColumnToSpace < ActiveRecord::Migration
  def self.up
     add_column :spaces, :repository, :boolean, :default => false
  end

  def self.down
    remove_column :spaces, :repository
  end
end
