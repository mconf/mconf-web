class AddColumnPublicSpace < ActiveRecord::Migration
  def self.up
    add_column :spaces, :public, :boolean, :default=>false
  end

  def self.down
    remove_column :spaces, :public
  end
end