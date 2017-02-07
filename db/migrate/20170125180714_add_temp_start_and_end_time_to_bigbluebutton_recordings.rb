class AddTempStartAndEndTimeToBigbluebuttonRecordings < ActiveRecord::Migration
  def up
    add_column :bigbluebutton_recordings, :temp_start_time, :decimal, precision: 14, scale: 0
    add_column :bigbluebutton_recordings, :temp_end_time, :decimal, precision: 14, scale: 0
  end
  def down
    remove_column :bigbluebutton_recordings, :temp_start_time
    remove_column :bigbluebutton_recordings, :temp_end_time
  end
end
