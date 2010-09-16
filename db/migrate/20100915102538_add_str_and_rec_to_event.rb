class AddStrAndRecToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :streaming_by_default, :boolean, :default => true
    add_column :events, :recording_by_default, :boolean, :default => true
  end

  def self.down
    remove_column :events, :streaming_by_default
    remove_column :events, :recording_by_default
  end
end
