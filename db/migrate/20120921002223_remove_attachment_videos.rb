class RemoveAttachmentVideos < ActiveRecord::Migration
  def up
    drop_table :attachment_videos
  end

  def down
    throw ActiveRecord::IrreversibleMigration
  end
end
