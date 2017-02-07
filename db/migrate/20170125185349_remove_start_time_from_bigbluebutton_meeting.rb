class RemoveStartTimeFromBigbluebuttonMeeting < ActiveRecord::Migration
  def change
    remove_column :bigbluebutton_meetings, :start_time, :datetime
  end
end
