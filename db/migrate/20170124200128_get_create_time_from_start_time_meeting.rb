class GetCreateTimeFromStartTimeMeeting < ActiveRecord::Migration
  def up
    BigbluebuttonMeeting.where(create_time: nil).each do |meeting|
      meeting.update_attributes( create_time: meeting.start_time.to_i )
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Can't undo the updating of create_time"
  end
end
