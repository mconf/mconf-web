class AddManualConfToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :manual_configuration, :boolean, :default => false
  end

  def self.down
    remove_column :events, :manual_configuration
  end
end
