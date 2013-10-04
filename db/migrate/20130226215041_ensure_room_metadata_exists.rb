class EnsureRoomMetadataExists < ActiveRecord::Migration
  def self.up
    BigbluebuttonRoom.all.each do |room|
      title = room.metadata.where(:name => 'mconfweb-title').first
      room.metadata.create(:name => 'mconfweb-title') if title.nil?
      description = room.metadata.where(:name => 'mconfweb-description').first
      room.metadata.create(:name => 'mconfweb-description') if description.nil?
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration, "Can't know for sure what metadata should be removed"
  end
end
