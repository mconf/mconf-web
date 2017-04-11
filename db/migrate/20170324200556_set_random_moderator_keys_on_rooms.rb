class SetRandomModeratorKeysOnRooms < ActiveRecord::Migration
  def up
    BigbluebuttonRoom.find_each do |room|
      room.update_attributes(moderator_key: SecureRandom.hex(8))
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
