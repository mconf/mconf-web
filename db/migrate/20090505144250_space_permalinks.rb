class SpacePermalinks < ActiveRecord::Migration
  def self.up
    add_column :spaces, :permalink, :string
  end

  def self.down
    remove_column :spaces, :permalink
  end
end
