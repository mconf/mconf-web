class RemoveStartAndEndTimeFromBigbluebuttonRecordings < ActiveRecord::Migration
  def up
    remove_column :bigbluebutton_recordings, :start_time
    remove_column :bigbluebutton_recordings, :end_time
  end

  def down
    add_column :bigbluebutton_recordings, :start_time, :datetime
    add_column :bigbluebutton_recordings, :end_time, :datetime
  end
end
