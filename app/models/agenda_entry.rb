# Copyright 2008-2010 Universidad Politécnica de Madrid and Agora Systems S.A.
#
# This file is part of VCC (Virtual Conference Center).
#
# VCC is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# VCC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with VCC.  If not, see <http://www.gnu.org/licenses/>.

class AgendaEntry < ActiveRecord::Base
  belongs_to :agenda
  has_many :attachments, :dependent => :destroy
  accepts_nested_attributes_for :attachments, :allow_destroy => true
  attr_accessor :author
  attr_accessor :setting_times
  acts_as_stage
  
  #Attributes for Conference Manager
  attr_accessor :streaming
  attr_accessor :recording

  acts_as_content :reflection => :agenda
  
  # Minimum duration IN MINUTES of an agenda entry that is NOT excluded from recording 
  MINUTES_NOT_EXCLUDED =  30
  
  before_validation do |agenda_entry|
    # Fill attachment fields
     agenda_entry.attachments.each do |a|
      a.space  ||= agenda_entry.agenda.event.space
      a.event  ||= agenda_entry.agenda.event
      a.author ||= agenda_entry.author    
    end     
  end
  
  def validate

    unless self.setting_times
      if self.title.blank?
        self.errors.add_to_base(I18n.t('agenda.entry.error.missing_title'))
      end
    end
    
    if self.agenda.blank?
      
      self.errors.add_to_base(I18n.t('agenda.entry.error.missing_agenda'))
      
    elsif (self.start_time.blank? || self.end_time.blank?)
      
      self.errors.add_to_base(I18n.t('agenda.entry.error.missing_time'))
      
    elsif (self.start_time > self.end_time)
      
      self.errors.add_to_base(I18n.t('agenda.entry.error.disordered_times'))
      
    elsif (self.start_time.to_date != self.end_time.to_date)
      
      self.errors.add_to_base(I18n.t('agenda.entry.error.several_days'))
      
    # if the event has no start_date, then there won't be any agenda entries or dividers, so the next validations should be skipped
    elsif !(self.agenda.event.start_date.blank?)
  
      if (self.end_time.to_date - self.agenda.event.start_date.to_date) >= Event::MAX_DAYS
        self.errors.add_to_base(I18n.t('agenda.entry.error.date_out_of_event', :max_days => Event::MAX_DAYS))
        return
      elsif (self.agenda.event.end_date.to_date - self.start_time.to_date) >= Event::MAX_DAYS
        self.errors.add_to_base(I18n.t('agenda.entry.error.date_out_of_event', :max_days => Event::MAX_DAYS))
        return        
      end

      self.agenda.contents_for_day(self.event_day).each do |content|
        next if ( (content.class == AgendaEntry) && (content.id == self.id) )

        if (self.start_time <= content.start_time) && (self.end_time >= content.end_time)
          unless (content.start_time == content.end_time) && ((content.start_time == self.start_time) || (content.start_time == self.end_time))
            self.errors.add_to_base(I18n.t('agenda.entry.error.coinciding_times'))
            return
          end
        elsif (content.start_time..content.end_time) === self.start_time
          unless ( self.start_time == content.start_time || self.start_time == content.end_time ) then
            self.errors.add_to_base(I18n.t('agenda.entry.error.coinciding_times'))
            return
          end
        elsif (content.start_time..content.end_time) === self.end_time
          unless ( self.end_time == content.start_time || self.end_time == content.end_time ) then
            self.errors.add_to_base(I18n.t('agenda.entry.error.coinciding_times'))
            return
          end
        end
      end
    end

  end
  
  validate_on_create do |entry|
    if (entry.event.vc_mode == Event::VC_MODE.index(:meeting)) || (entry.event.vc_mode == Event::VC_MODE.index(:teleconference))
      cm_s = ConferenceManager::Session.new(:name => "none", :initDate=> entry.start_time, :endDate=>entry.end_time, :event_id => entry.agenda.event.cm_event_id ) 
      begin
        cm_s.save
        entry.cm_session_id = cm_s.id
      rescue => e
        entry.errors.add_to_base(e.to_s) 
      end        
    end
  end
  
  validate_on_update do |entry|
    if ((entry.event.vc_mode == Event::VC_MODE.index(:meeting)) || (entry.event.vc_mode == Event::VC_MODE.index(:teleconference))) && !entry.agenda.event.past?  
      cm_s = entry.cm_session
      my_params = {:name => entry.title, :recording => entry.recording ? entry.recording : cm_s.recording, :streaming => entry.streaming ? entry.streaming : cm_s.streaming, :initDate=> entry.start_time, :endDate=>entry.end_time, :event_id => entry.agenda.event.cm_event_id}
      if entry.cm_session?
        cm_s.load(my_params) 
      else
        entry.errors.add_to_base(I18n.t('event.error.cm_connection'))
      end
      begin        
        cm_s.save
      rescue => e
       if cm_s.present?  
         entry.errors.add_to_base(e.to_s) 
       end  
      end       
    end    
  end
  
  before_destroy do |entry|
    #Delete session in Conference Manager if event is not in-person
    if (entry.event.vc_mode == Event::VC_MODE.index(:meeting)) || (entry.event.vc_mode == Event::VC_MODE.index(:teleconference))
      begin
        cm_s = entry.cm_session     
        cm_s.destroy    
      rescue => e  
        entry.errors.add_to_base(I18n.t('agenda.entry.error.delete'))
        false
      end     
    end 
  end
  
  
  before_save do |entry|
    if entry.embedded_video.present?
      entry.video_thumbnail  = entry.get_background_from_embed
    end      
  end
  
 
  after_create do |entry|
     # This method should be uncomment when agenda_entry was created in one step (uncomment also after_update 2nd line)
#    entry.attachments.each do |a|
#      FileUtils.mkdir_p("#{RAILS_ROOT}/attachments/conferences/#{a.event.permalink}/#{entry.title.gsub(" ","_")}")
#      FileUtils.ln(a.full_filename, "#{RAILS_ROOT}/attachments/conferences/#{a.event.permalink}/#{entry.title.gsub(" ","_")}/#{a.filename}")
#    end
    
    if entry.uid.nil? or entry.uid.eql? ''
      entry.uid = entry.generate_uid + "@" + entry.id.to_s + ".vcc"
      entry.save
    end
  end
 
  after_update do |entry|
    #Delete old attachments
    # FileUtils.rm_rf("#{RAILS_ROOT}/attachments/conferences/#{entry.event.permalink}/#{entry.title.gsub(" ","_")}")
    #create new attachments
    entry.attachments.reload
    entry.attachments.each do |a|
      # check if the attachment had already been created
      unless File.exist?("#{RAILS_ROOT}/attachments/conferences/#{a.event.permalink}/#{entry.title.gsub(" ","_")}/#{a.filename}")
        FileUtils.mkdir_p("#{RAILS_ROOT}/attachments/conferences/#{a.event.permalink}/#{entry.title.gsub(" ","_")}")
        FileUtils.ln(a.full_filename, "#{RAILS_ROOT}/attachments/conferences/#{a.event.permalink}/#{entry.title.gsub(" ","_")}/#{a.filename}")
      end
    end
  end
  
  after_save do |entry|
    entry.agenda.event.syncronize_date
  end
  
  
  after_destroy do |entry|  
    if entry.title.present?
      FileUtils.rm_rf("#{RAILS_ROOT}/attachments/conferences/#{entry.event.permalink}/#{entry.title.gsub(" ","_")}")
    end
    entry.event.syncronize_date
  end
  
  def event
    self.agenda.event
  end
  
  
  def cm_session?
    cm_session.present?
  end
  
  def cm_session
    begin
      @cm_session ||= ConferenceManager::Session.find(self.cm_session_id, :params=> {:event_id => self.agenda.event.cm_event_id})
    rescue
      nil
    end  
  end
  
  def recording?
    if embedded_video.present?
      return true
    else
      return cm_session.try(:recording?)
    end   
  end
  
  def thumbnail
    if video_thumbnail
      return video_thumbnail
    else
      "default_background.jpg"
    end
  end
  
  def video_player
    if embedded_video
      return embedded_video
    else
      return player
    end
  end
  
  def streaming?
    cm_session.try(:streaming?)
  end
  
  def initDate
    DateTime.strptime(cm_session.initDate)
  end
  
  def endDate
    DateTime.strptime(cm_session.endDate)
  end
  
  def past?
    return end_time.past?
  end  
  
  def name
    cm_session.try(:name)
  end
  
  def can_edit_hours?
    #an user can only edit hours if the event is in person or is virtual and future
    return true unless cm_session? && past? 
  end
  
  #Return  a String that contains a html with the video player for this session
  def player
    begin
      cm_player_session ||= ConferenceManager::PlayerSession.find(:one,:from=>"/events/#{self.agenda.event.cm_event_id}/sessions/#{self.cm_session.id}/player")
      cm_player_session.html
    rescue
      nil
    end
  end

  def has_error?
    return self.cm_error.present?
  end
  
  #returns the day of the agenda entry, 1 for the first day, 2 for the second day, ...
  def event_day
    return ((self.start_time - event.start_date + event.start_date.hour.hours)/86400).floor + 1
  end
  
  
  def get_background_from_embed
    start_key = "image="   #this is the key where the background url starts
    end_key = "&"      #this is the key where the background url ends
    start_index = embedded_video.index(start_key)
    if start_index
      temp_str = embedded_video[start_index+start_key.length..-1]
      endindex = temp_str.index(end_key)
      if endindex==nil
        return nil
      end
      result = temp_str[0..endindex-1]
      return result
    else
      return nil
    end
  end
    
  def is_happening_now?
    return start_time.past? && end_time.future?    
  end
    
  def generate_uid
     
     Time.now.strftime("%Y%m%d%H%M%S").to_s + (1..18).collect { (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }.join.to_s.downcase 
    
  end
end
