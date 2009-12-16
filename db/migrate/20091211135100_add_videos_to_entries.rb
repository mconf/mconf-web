class AddVideosToEntries < ActiveRecord::Migration
  def self.up
   add_column :agenda_entries, :embedded_video, :text
   add_column :agenda_entries, :video_thumbnail, :text
  end

  def self.down
   remove_column :agenda_entries, :embedded_video 
   remove_column :agenda_entries, :video_thumbnail
  end
end
