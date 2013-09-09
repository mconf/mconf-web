class AddRecordingOptions < ActiveRecord::Migration
  def self.up
    add_column :events, :recording_type, :integer, :default => 0 # Event::RECORDING_TYPE.index(:automatic)
    remove_column :events, :recording_by_default
  end

  def self.down
    remove_column :events, :recording_type
    add_column :events, :recording_by_default, :boolean, :default => true
  end
end
