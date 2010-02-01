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
  acts_as_stage
  
  #acts_as_content :reflection => :agenda
  
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
  
  before_save do |entry|
    if entry.embedded_video.present?
      entry.video_thumbnail  = entry.get_background_from_embed
    end    
    
  end
  
  after_save do |entry|
    entry.attachments.each do |a|
      FileUtils.mkdir_p("#{RAILS_ROOT}/attachments/conferences/#{a.event.name}/#{entry.title.gsub(" ","_")}")
      FileUtils.ln(a.full_filename, "#{RAILS_ROOT}/attachments/conferences/#{a.event.name}/#{entry.title.gsub(" ","_")}/#{a.filename}")
    end
  end
  
  after_destroy do |entry|    
    FileUtils.rm_rf("#{RAILS_ROOT}/attachments/conferences/#{entry.agenda.event.name}/#{entry.title.gsub(" ","_")}")
  end
  
  def validate
    # Check title presence
    if self.title.empty?
      errors.add_to_base(I18n.t('agenda.error.omit_title'))
    end
    
=begin
    # Check start and end times presence
    if self.start_time.nil? || self.end_time.nil? 
      errors.add_to_base(I18n.t('agenda.error.omit_date'))
    else
      # Check start time is previous to end time
      unless self.start_time <= self.end_time
        errors.add_to_base(I18n.t('agenda.error.dates'))
      end
       
      # Check the times don't overlap with existing entries 
      for entry in self.agenda.agenda_entries_for_day(self.start_time.day - self.agenda.event.start_date.day)
        if (self.id != entry.id) then
          if ((self.start_time >= entry.start_time) && (self.start_time < entry.end_time))
            errors.add_to_base(I18n.t('agenda.error.start_time_overlaps'))
          end
          if ((self.end_time > entry.start_time) && (self.end_time <= entry.end_time))
            errors.add_to_base(I18n.t('agenda.error.end_time_overlaps'))
          end
          if ((self.start_time < entry.start_time) && (self.end_time > entry.end_time))
            errors.add_to_base(I18n.t('agenda.error.overlaps'))
          end
          if ((self.start_time == entry.start_time) && (self.end_time == entry.end_time))
            errors.add_to_base(I18n.t('agenda.error.overlaps'))
          end          
        end   
      end
    end
=end
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
  
end
