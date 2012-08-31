# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

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
  
  validate :validate_method
  def validate_method

    return if self.agenda.blank? || self.time.blank?
    
    if (self.agenda.event.vc_mode != Event::VC_MODE.index(:in_person)) && (self.time < Time.now)
    
      self.errors.add(:base, I18n.t('agenda.divider.error.past_times'))
    
    # if the event has no start_date, then there won't be any agenda entries or dividers, so these validations should be skipped
    elsif !(self.agenda.event.start_date.blank?)
      if (self.time.to_date - self.agenda.event.start_date.to_date) >= Event::MAX_DAYS
        self.errors.add(:base, I18n.t('agenda.divider.error.date_out_of_event', :max_days => Event::MAX_DAYS))
        return
      elsif (self.agenda.event.end_date.to_date - self.time.to_date) >= Event::MAX_DAYS
        self.errors.add(:base, I18n.t('agenda.divider.error.date_out_of_event', :max_days => Event::MAX_DAYS))
        return        
      end

      self.agenda.contents_for_day(self.event_day).each do |content|
        next if ( (content.class == AgendaDivider) && (content.id == self.id) )
        next if (content.start_time == self.time) || (content.end_time == self.time)
 
        if (content.start_time..content.end_time) === self.time
          self.errors.add(:base, I18n.t('agenda.divider.error.coinciding_times'))
          return
        end
      end
    end
    
  end

  after_save do |divider|
    divider.event.agenda.touch
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

end
