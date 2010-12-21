class CreateAttachmentVideos < ActiveRecord::Migration
  
  def self.up
    create_table :attachment_videos do |t|    
      t.string   :type
      t.integer  :size
      t.string   :content_type
      t.string   :filename
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :space_id
      t.integer  :event_id
      t.integer  :author_id
      t.string   :author_type
      t.integer  :agenda_entry_id
      t.integer  :version_child_id
      t.integer  :version_family_id     
    end   
  end

  def self.down
    drop_table :attachment_videos
  end
  
end
