class RemoveMetadataFromRooms < ActiveRecord::Migration
  def up
    BigbluebuttonRoom.all.each do |room|
      room.metadata.where(:name => 'mconfweb-title').destroy_all
      room.metadata.where(:name => 'mconfweb-description').destroy_all
    end
    # not worth removing from recordings, since the metadata is already in the web conference
    # servers and will be added again in the next sync
  end

  # Not exactly the inverse of up because we lose the values from the metadata destroyed.
  # But better than not allowing a rollback.
  def down
    BigbluebuttonRoom.all.each do |room|
      title = room.metadata.where(:name => 'mconfweb-title').first
      room.metadata.create(:name => 'mconfweb-title') if title.nil?
      description = room.metadata.where(:name => 'mconfweb-description').first
      room.metadata.create(:name => 'mconfweb-description') if description.nil?
    end
  end
end
