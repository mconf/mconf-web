class RemoveStartTimeFromBigbluebuttonRecordings < ActiveRecord::Migration
  def up
    remove_column :bigbluebutton_recordings, :start_time
  end

  def down
    add_column :bigbluebutton_recordings, :start_time, :datetime
  end
end
