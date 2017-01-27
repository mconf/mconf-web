class RenameTempStartTimeToStartTimeOnBigbluebuttonRecording < ActiveRecord::Migration
  def self.up
    rename_column :bigbluebutton_recordings, :temp_start_time, :start_time
  end

  def self.down
    rename_column :bigbluebutton_recordings, :start_time, :temp_start_time
  end
end
