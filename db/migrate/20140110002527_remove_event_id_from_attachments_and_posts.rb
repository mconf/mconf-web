class RemoveEventIdFromAttachmentsAndPosts < ActiveRecord::Migration
  def up
    remove_column :attachments, :event_id
    remove_column :posts, :event_id
  end

  def down
    add_column :posts, :event_id, :integer
    add_column :attachments, :event_id, :integer
  end
end
