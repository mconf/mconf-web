class DisableSpace < ActiveRecord::Migration
  def self.up
    add_column :spaces, :disabled, :boolean, :default => false
  end

  def self.down
    remove_column :spaces, :disabled
  end
end
