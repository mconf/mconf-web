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

class Agenda < ActiveRecord::Base
  
  
  class FlashException < StandardError; end
  class FlashError < FlashException; end
  class FlashNotice < FlashException; end
  class FlashSuccess < FlashException; end
  attr_accessor :icalendar_file
  attr_accessor :notices
  
  belongs_to :event
  has_many :agenda_entries, :dependent => :destroy, :order => 'start_time ASC'
  has_many :agenda_dividers, :dependent => :destroy, :order => 'id DESC'
  has_many :agenda_record_entries
  has_many :attachments, :through => :agenda_entries
  
  before_validation :from_icalendar
  
  acts_as_container :contents => [:agenda_entries, :agenda_dividers],
                    :scope => {:order => 'start_time ASC, type ASC'}
  acts_as_content :reflection => :event

  def space
    event.space
  end
  
  def validate
    errors.add_to_base(@icalendar_file_errors) if @icalendar_file_errors.present?
  end
  
  def start_date
    event.start_date
  end
  
  def end_date
    event.end_date
  end
    
  def contents_for_day(i)
    if start_date
      contents.all(:conditions => [
                   "start_time >= :day_start AND start_time < :day_end",
                     {:day_start => start_date.to_date + (i-1).day,
                     :day_end => start_date.to_date + i.day} ],
                  :order=>'start_time ASC, type ASC'
                 ).each{|content| content.reload}
    else
      return Array.new
    end
  end
  
  #returns the hour of the last agenda_entry
  def last_hour_for_day(i)
    if start_date.nil?
      return Time.now
    end
    ordered_entries = contents.all(:conditions => [
                   "start_time >= :day_start AND start_time < :day_end",
                     {:day_start => start_date.to_date + (i-1).day,
                     :day_end => start_date.to_date + i.day} ],
                  :order=>'end_time ASC'
                 )
    unless ordered_entries.empty?
      ordered_entries.last.end_time
    else
      if (start_date + i.days).day == Time.now.day
        Time.now
      else
        self.start_date.to_date + (i-1).days + 9.hour #9 in the morning
      end  
    end  
  end
  
  # Used to calculate event start time from agenda contents
  def recalculate_start_time
    unless contents.blank?
      return contents.first.start_time
    else
      return nil
    end
  end
  
  # Used to calculate event end time from agenda contents
  def recalculate_end_time
    unless contents.blank?
      return contents.all(:order=>'end_time ASC').last.end_time
    else
      return nil
    end
  end
       
  def first_video_entry_id
    for entry in agenda_entries  
      if entry.recording?
        return entry.id       
      end    
    end
    return 0
  end
 
  def has_entries_with_video?
    return first_video_entry_id!=0
  end
  
  
  def has_past_session_with_video?
    for entry in agenda_entries
      if entry.past? && entry.recording?
        return true
      end
    end    
    return false
  end
  
  def from_icalendar    
    
    return unless @icalendar_file.present?
    
  
    begin      
    
    @icalendar_file = Vpim::Icalendar.decode(@icalendar_file)   
    
     
    has_updated = false;
    has_conflict = false;
    has_outofbounds = false;
    updated_entries = Array.new();
    conflictive_entries = Array.new();
    outofbounds_entries = Array.new();
    total_entries = Array.new();
    
    @icalendar_file.each do |cal|
      
      entries = cal.events
      
      
      entries.each do |e|
        puts "entry uid: " + e.uid.to_s + " agenda id = " + self.id.to_s
        if !(agenda_entry = AgendaEntry.find(:first, :conditions => ["agenda_id = ? AND uid = ?", self.id, e.uid])).nil?
           if agenda_entry.updated_at == agenda_entry.created_at #Not modified on VCC
            has_updated = true;
            updated_entries.push(agenda_entry.title)
            agenda_entry.title = e.summary.to_s
            agenda_entry.description = e.description.to_s
            agenda_entry.start_time = e.dtstart.to_s
            agenda_entry.end_time = e.dtend.to_s
            agenda_entry.speakers = e.organizer.to_s            
            total_entries.push(agenda_entry.title);
            next
            
          else #Modified on VCC, conflict and error
            has_conflict = true;
            conflictive_entries.push(agenda_entry.title)
            next
          end
        end
        
        
        agenda_entry = AgendaEntry.new()
        
        agenda_entry.agenda = self
        
        agenda_entry.title = e.summary.to_s
        agenda_entry.description = e.description.to_s
        agenda_entry.start_time = e.dtstart.to_s
        agenda_entry.end_time = e.dtend.to_s
        agenda_entry.speakers = e.organizer.to_s
        agenda_entry.uid = e.uid        
        
        if (!((self.event.start_date < agenda_entry.start_time)&&(self.event.end_date > agenda_entry.end_time)))
          has_outofbounds = true;
          outofbounds_entries.push(agenda_entry.title)
          next
        end           
        
        agenda_entry.save!
        total_entries.push(agenda_entry.title);
        
      end     
      
    end        
    
    self.notices = I18n.t("icalendar.importMessage1") + (outofbounds_entries.length + conflictive_entries.length + total_entries.length).to_s +
      I18n.t("icalendar.importMessage2") + "<br>"
     
      self.notices = self.notices + total_entries.length.to_s  + I18n.t("icalendar.importMessage3") + "<br><br>"
    
    if has_updated || has_conflict || has_outofbounds
      self.notices = self.notices + I18n.t("icalendar.report")
    end
    
    if has_updated
      if updated_entries.length == 1 
        self.notices = self.notices + I18n.t("icalendar.updated1")
      else        
        self.notices = self.notices + updated_entries.length.to_s + I18n.t("icalendar.updatedn")
      end 
    end    
    
        
    if has_conflict
      if conflictive_entries.length == 1 
        self.notices = self.notices + I18n.t("icalendar.conflictive1")
      else        
        self.notices = self.notices + conflictive_entries.length.to_s + I18n.t("icalendar.conflictiven")
      end 
    end 
    
    if has_outofbounds
      if outofbounds_entries.length == 1 
        self.notices = self.notices + I18n.t("icalendar.outbounds1")
      else        
        self.notices = self.notices  + outofbounds_entries.length.to_s + I18n.t("icalendar.outboundsn")
      end 
    end 
 
    rescue Exception => exc
      @icalendar_file_errors = I18n.t("icalendar.error_import")      
    end
  end
  
  authorization_delegate(:space,:as => :content)
end
