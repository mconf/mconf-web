class MartchRecordingsToMeetingsCloserCreateTime < ActiveRecord::Migration
  def up
    BigbluebuttonRecording.all.each do |rec|
      rec.update_attributes(
        meeting_id: find_matching_meeting_closer_create_time(rec)
      )
    end
  end

  def find_matching_meeting_closer_create_time(recording)
    meeting_id = recording.meeting_id
    if meeting_id.nil?
      meeting = BigbluebuttonMeeting.where("meetingid = ? AND created_at > ? AND created_at < ?",
                recording.meetingid, Time.at(recording.start_time)-2.minutes, Time.at(recording.start_time)+2.minutes).last

      if meeting.nil?
        meeting_id = nil
      else
        if BigbluebuttonRecording.find_by_meeting_id(meeting.id).present?
          meeting_id = nil
        else
          meeting_id = meeting.id
        end
      end

      unless meeting_id.nil?
        puts "Meeting found for recording id-#{recording.id}: Meeting id-#{meeting.id}"
      end
    end

    meeting_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Can't undo matching of recordings to their meetings"
  end
end

