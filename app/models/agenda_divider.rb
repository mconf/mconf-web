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

class AgendaDivider < ActiveRecord::Base
  belongs_to :agenda
  
  acts_as_content :reflection => :agenda
  acts_as_stage
  acts_as_resource
  
  default_scope :order => 'start_time ASC'
  
  validates_presence_of :title, :agenda, :time

  before_validation do |divider|
    if divider.start_time
      divider.end_time = divider.start_time
    end
  end
  
  def validate

    return if self.agenda.blank? || self.time.blank?
    
    # if the event has no start_date, then there won't be any agenda entries or dividers, so these validations should be skipped
    if !(self.agenda.event.start_date.blank?)
      if (self.time.to_date - self.agenda.event.start_date.to_date) >= Event::MAX_DAYS
        self.errors.add_to_base(I18n.t('agenda.divider.error.date_out_of_event', :max_days => Event::MAX_DAYS))
        return
      elsif (self.agenda.event.end_date.to_date - self.time.to_date) >= Event::MAX_DAYS
        self.errors.add_to_base(I18n.t('agenda.divider.error.date_out_of_event', :max_days => Event::MAX_DAYS))
        return        
      end

      self.agenda.contents_for_day(self.event_day).each do |content|
        next if ( (content.class == AgendaDivider) && (content.id == self.id) )
        next if (content.start_time == self.time) || (content.end_time == self.time)
 
        if (content.start_time..content.end_time) === self.time
          self.errors.add_to_base(I18n.t('agenda.divider.error.coinciding_times'))
          return
        end
      end
    end
    
  end

  after_save do |divider|
    divider.agenda.event.syncronize_date
  end

  after_destroy do |divider|  
    divider.agenda.event.syncronize_date
  end

  def space
    event.space
  end

  def event
    self.agenda.event
  end

   #returns the day of the agenda entry, 1 for the first day, 2 for the second day, ...
  def event_day
    return ((self.time - event.start_date + event.start_date.hour.hours)/86400).floor + 1
  end
  
  def time
    return start_time
  end

  authorization_delegate(:event,:as => :content)
  authorization_delegate(:space,:as => :content)
  
end