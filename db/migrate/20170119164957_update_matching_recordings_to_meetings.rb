class UpdateMatchingRecordingsToMeetings < ActiveRecord::Migration
  def up
  	BigbluebuttonRecording.all.each do |rec|
  	  rec.update_attributes(
  	  	meeting_id: BigbluebuttonRecording.find_matching_meeting(rec).try(:id)
  	  )
  	end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Can't undo matching of recordings to their meetings"
  end
end
