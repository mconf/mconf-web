class AddVideosToEntries < ActiveRecord::Migration
  def self.up
   add_column :agenda_entries, :embedded_video, :text
  end

  def self.down
   remove_column :agenda_entries, :embedded_video 
  end
end
