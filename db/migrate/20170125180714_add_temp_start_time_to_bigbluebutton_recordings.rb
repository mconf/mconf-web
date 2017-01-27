class AddTempStartTimeToBigbluebuttonRecordings < ActiveRecord::Migration
  def up
    add_column :bigbluebutton_recordings, :temp_start_time, :decimal, precision: 14, scale: 0
  end
  def down
    remove_column :bigbluebutton_recordings, :temp_start_time
  end
end
