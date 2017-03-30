class SetRandomModeratorKeysOnRooms < ActiveRecord::Migration
  def up
    BigbluebuttonRoom.find_each do |room|
      room.update_attributes(moderator_key: SecureRandom.urlsafe_base64(16))
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
