class MakeMeetingsForUnmatchedRecordings < ActiveRecord::Migration
  def up 
    BigbluebuttonRecording.all.each do |rec|
      if rec.meeting_id.nil?
        unless rec.room_id.nil?
          BigbluebuttonMeeting.create do |m|
            creator_data = find_creator_data(rec)
            m.server_id = rec.server_id
            m.room_id = rec.room_id
            m.meetingid = rec.meetingid
            m.name = rec.name
            m.running = false
            m.recorded = true
            m.creator_id = creator_data[0]
            m.creator_name = creator_data[1]
            m.server_url = nil
            m.server_secret = nil
            m.create_time = rec.start_time
            m.ended = true
          end
          rec.update_attributes(meeting_id: BigbluebuttonRecording.find_matching_meeting(rec).try(:id))
        end
      end
    end    
  end

  def find_creator_data(recording)
    creator_data = []
    if recording.room.owner.is_a?(User)
      creator_id = recording.room.owner.id
      creator_name = recording.room.owner.name
    elsif recording.room.owner.is_a?(Space)
      creator_id = recording.room.owner.admins.first.id
      creator_name = recording.room.owner.admins.first.name
    end
    creator_data = [creator_id, creator_name]
  end

end
