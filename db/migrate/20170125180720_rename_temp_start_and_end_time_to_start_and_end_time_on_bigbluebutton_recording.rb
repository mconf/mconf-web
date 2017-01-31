class RenameTempStartAndEndTimeToStartAndEndTimeOnBigbluebuttonRecording < ActiveRecord::Migration
  def self.up
    rename_column :bigbluebutton_recordings, :temp_start_time, :start_time
    rename_column :bigbluebutton_recordings, :temp_end_time, :end_time
  end

  def self.down
    rename_column :bigbluebutton_recordings, :start_time, :temp_start_time
    rename_column :bigbluebutton_recordings, :end_time, :temp_end_time
  end
end
