class AddVideoTypeToAgendaEntry < ActiveRecord::Migration
  def self.up
    add_column :agenda_entries, :video_type, :integer

    #for "in person" events this param will be AgendaEntry::VIDEO_TYPE.index(:embedded) or AgendaEntry::VIDEO_TYPE.index(:none)
    #for "automatic" events we change discard_automatic_video to video_type = AgendaEntry::VIDEO_TYPE.index(:embedded)
    #and leave with video_type = AgendaEntry::VIDEO_TYPE.index(:automatic) the others
    if defined? AgendaEntry
      AgendaEntry.reset_column_information
      AgendaEntry.record_timestamps=false

      AgendaEntry.all.each{ |a|
        if a.event.respond_to?("uses_conference_manager?")
          if a.event != nil && a.event.uses_conference_manager? && a.discard_automatic_video==true
            if a.embedded_video.present? && a.embedded_video !=""
              a.update_attribute(:video_type,AgendaEntry::VIDEO_TYPE.index(:embedded))
            else
              a.update_attribute(:video_type,AgendaEntry::VIDEO_TYPE.index(:none))
            end
          elsif a.event != nil && a.event.uses_conference_manager? && a.discard_automatic_video==false
            a.update_attribute(:video_type,AgendaEntry::VIDEO_TYPE.index(:automatic))
          elsif a.event != nil && !a.event.uses_conference_manager? && a.embedded_video.present? && a.embedded_video !=""
            a.update_attribute(:video_type,AgendaEntry::VIDEO_TYPE.index(:embedded))
          elsif a.event != nil && !a.event.uses_conference_manager? && !a.embedded_video.present?
            a.update_attribute(:video_type,AgendaEntry::VIDEO_TYPE.index(:none))
          end
        end
      }
    end

    remove_column :agenda_entries, :discard_automatic_video
  end

  def self.down
    remove_column :agenda_entries, :video_type
    add_column :agenda_entries, :discard_automatic_video, :boolean, :default => false
  end
end
