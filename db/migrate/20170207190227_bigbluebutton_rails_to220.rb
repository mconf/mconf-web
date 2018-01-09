class BigbluebuttonRailsTo220 < ActiveRecord::Migration
  def up
    # remove start_time, it's now create_time only
    BigbluebuttonMeeting.where(create_time: nil).find_each do |meeting|
      meeting.update_attribute(:create_time, meeting.start_time.to_i)
    end
    remove_column :bigbluebutton_meetings, :start_time

    # adapt the content of some columns to another type
    add_column :bigbluebutton_recordings, :temp_start_time, :decimal, precision: 14, scale: 0
    add_column :bigbluebutton_recordings, :temp_end_time, :decimal, precision: 14, scale: 0
    BigbluebuttonRecording.find_each do |rec|
      rec.update_attributes(
        temp_start_time: rec.start_time.to_i,
        temp_end_time: rec.end_time.to_i
      )
    end
    remove_column :bigbluebutton_recordings, :start_time
    remove_column :bigbluebutton_recordings, :end_time
    rename_column :bigbluebutton_recordings, :temp_start_time, :start_time
    rename_column :bigbluebutton_recordings, :temp_end_time, :end_time

    create_table :bigbluebutton_attendees do |t|
      t.string :user_id
      t.string :external_user_id
      t.string :user_name
      t.decimal :join_time, precision: 14, scale: 0
      t.decimal :left_time, precision: 14, scale: 0
      t.integer :bigbluebutton_meeting_id
    end

    add_column :bigbluebutton_meetings, :finish_time, :decimal, precision: 14, scale: 0
    add_column :bigbluebutton_meetings, :got_stats, :string
    BigbluebuttonMeeting.reset_column_information # to be able to use #got_stats below

    # associate meetings with recordings and if no meeting is found, make a new one
    BigbluebuttonRecording.find_each do |rec|
      rec.update_attributes(
        meeting_id: BigbluebuttonRecording.find_matching_meeting(rec).try(:id)
      )
    end
    BigbluebuttonRecording.where(meeting_id: nil).find_each do |rec|
      rec.update_attributes(
        meeting_id: find_matching_meeting_closer_create_time(rec)
      )
    end
    BigbluebuttonRecording.where(meeting_id: nil).where.not(room_id: nil).find_each do |rec|
      meeting = BigbluebuttonMeeting.create do |m|
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
      rec.update_attributes(meeting_id: meeting.id)
      puts "Created a meeting for the recording id-#{rec.id}: Meeting id-#{meeting.id}"
    end
  end

  def find_matching_meeting_closer_create_time(recording)
    meeting = BigbluebuttonMeeting.where("meetingid = ? AND created_at > ? AND created_at < ?",
                                         recording.meetingid, Time.at(recording.start_time)-2.minutes, Time.at(recording.start_time)+2.minutes).first

    unless meeting.nil?
      unless BigbluebuttonRecording.find_by(meeting_id: meeting.id).present?
        meeting_id = meeting.id
      end
    end

    unless meeting_id.nil?
      puts "Meeting found for recording id-#{recording.id}: Meeting id-#{meeting.id}"
    end

    meeting_id
  end

  def find_creator_data(recording)
    creator_data = []
    if recording.room.owner.is_a?(User)
      creator_id = recording.room.try(:owner).try(:id)
      creator_name = recording.room.try(:owner).try(:name)
    elsif recording.room.owner.is_a?(Space)
      creator_id = recording.room.try(:owner).try(:admins).try(:first).try(:id)
      creator_name = recording.room.try(:owner).try(:admins).try(:first).try(:name)
    end
    creator_data = [creator_id, creator_name]
  end

  def down
	  raise ActiveRecord::IrreversibleMigration, "Can't undo due to loss of values during migration"
  end
end
