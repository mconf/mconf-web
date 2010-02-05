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
  belongs_to :event
  has_many :agenda_entries, :dependent => :destroy
  has_many :agenda_record_entries
  has_many :attachments, :through => :agenda_entries
  
  #acts_as_container :content => :agenda_entries
  #acts_as_content :reflection => :event

  def agenda_entries_for_day(i)
    all_entries = []
    for entry in agenda_entries
      if entry.start_time > (event.start_date + i.day).to_date && entry.start_time < (event.start_date + 1.day + i.day).to_date
        all_entries << entry
      end
    end
    all_entries.sort!{|a,b| a.start_time <=> b.start_time}
  end
  
  #returns a hash with the id of the entries and the thumbnail of the associated video
  def get_videos
    array_of_days = {}
    for day in 0..event.days-1
      entries_with_video = {}
      for entry in agenda_entries_for_day(day)        
        if entry.embedded_video.present?
          entries_with_video[entry.id] = entry       
        end        
      end
      array_of_days[day] = entries_with_video      
    end
    return array_of_days
  end
  
  
  def first_video_entry_id
     for entry in agenda_entries  
        if entry.embedded_video.present?
          return entry.id       
        end    
     end
     return 0
 end
 
 def has_entries_with_video?
   return first_video_entry_id!=0
 end
 
end
