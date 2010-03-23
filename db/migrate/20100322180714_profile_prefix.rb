class ProfilePrefix < ActiveRecord::Migration
  def self.up
    rename_column :profiles, :prefix, :prefix_key
  end

  def self.down
    rename_column :profiles, :prefix_key, :prefix
  end
end
