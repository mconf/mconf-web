class AddDiscardVideoToAgendaEntry < ActiveRecord::Migration
  def self.up
    add_column :agenda_entries, :discard_automatic_video, :boolean, :default => false
    
    AgendaEntry.reset_column_information
    AgendaEntry.record_timestamps=false
    
    AgendaEntry.all.select{ |a| 
      a.event != nil && a.event.uses_conference_manager? && a.embedded_video.present? && a.embedded_video !="" 
    }.each{ |ae| ae.update_attribute(:discard_automatic_video, true)}
    
  end

  def self.down
    remove_column :agenda_entries, :discard_automatic_video
  end
end
