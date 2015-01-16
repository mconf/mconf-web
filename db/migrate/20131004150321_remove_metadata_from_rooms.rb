class RemoveMetadataFromRooms < ActiveRecord::Migration
  def up
    execute "DELETE FROM bigbluebutton_metadata WHERE owner_type='BigbluebuttonRoom' AND name='mconfweb-title';"
    execute "DELETE FROM bigbluebutton_metadata WHERE owner_type='BigbluebuttonRoom' AND name='mconfweb-description';"
    # not worth removing from recordings, since the metadata is already in the web conference
    # servers and will be added again in the next sync
  end

  # Not exactly the inverse of up because we lose the values from the metadata destroyed.
  # But better than not allowing a rollback.
  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
