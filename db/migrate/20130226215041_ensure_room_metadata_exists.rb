class EnsureRoomMetadataExists < ActiveRecord::Migration
  def self.up
    BigbluebuttonRoom.all.each do |room|
      title = room.metadata.where(:name => configatron.metadata.title).first
      room.metadata.create(:name => configatron.metadata.title) if title.nil?
      description = room.metadata.where(:name => configatron.metadata.description).first
      room.metadata.create(:name => configatron.metadata.description) if description.nil?
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration, "Can't know for sure what metadata should be removed"
  end
end
