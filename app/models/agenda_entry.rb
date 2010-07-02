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
  attr_accessor :author, :duration 
  acts_as_stage
  acts_as_content :reflection => :agenda
  acts_as_resource
  
  is_indexed :fields => ['title','description','speakers','start_time','end_time'],
             :include =>[{:class_name => 'Event',
                          :field => 'name',
                          :as => 'event_name',
                          :association_sql => "LEFT OUTER JOIN agendas ON (agendas.`id` = agenda_entries.`agenda_id`) LEFT OUTER JOIN events ON (events.`id` = agendas.`event_id`)"}],
             :concatenate => [ { :class_name => 'Profile',:field => 'full_name',:as => 'registered_speakers',
                                 :association_sql => "LEFT OUTER JOIN performances ON (performances.`stage_id` = agenda_entries.`id` AND performances.`stage_type` = 'AgendaEntry' AND performances.`agent_type` = 'User') LEFT OUTER JOIN profiles ON (profiles.`user_id` = performances.`agent_id`)"}]
  
  validates_presence_of :title
  validates_presence_of :agenda, :start_time, :end_time
  
  # Minimum duration IN MINUTES of an agenda entry that is NOT excluded from recording 
  MINUTES_NOT_EXCLUDED =  30
  
  before_validation do |agenda_entry|
    # Convert duration in end_time
    if agenda_entry.end_time.nil? || (agenda_entry.duration != agenda_entry.end_time - agenda_entry.start_time)
      agenda_entry.end_time = agenda_entry.start_time + agenda_entry.duration.to_i.minutes
    end
    
    # Fill attachment fields
     agenda_entry.attachments.each do |a|
      a.space  ||= agenda_entry.agenda.event.space
      a.event  ||= agenda_entry.agenda.event
      a.author ||= agenda_entry.author    
    end     
  end

  def validate

    return if self.agenda.blank? || self.start_time.blank? || self.end_time.blank?
      
    if(self.start_time > self.end_time)
    
      self.errors.add_to_base(I18n.t('agenda.entry.error.disordered_times'))

    elsif (self.end_time.to_date - self.start_time.to_date) >= Event::MAX_DAYS
      self.errors.add_to_base(I18n.t('agenda.entry.error.date_out_of_event', :max_days => Event::MAX_DAYS))
      
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
    
    if entry.uid.blank?
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
    entry.event.syncronize_date
    entry.event.agenda.touch
  end
  
  
  after_destroy do |entry|  
    if entry.title.present?
      FileUtils.rm_rf("#{RAILS_ROOT}/attachments/conferences/#{entry.event.permalink}/#{entry.title.gsub(" ","_")}")
    end
    entry.event.syncronize_date
  end
  
  def duration
    @duration ||= end_time - start_time
  end
  
  def space
    event.present? ? event.space : nil 
  end
  
  def event
    agenda.present? ? agenda.event : nil
  end
    
  def recording?
    embedded_video.present? || cm_recording?
  end

  def streaming?
    cm_streaming?
  end
 
  def thumbnail
    video_thumbnail.present? ?
      video_thumbnail :
      "default_background.jpg"
  end
  
  def video_player
    embedded_video || player
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
  
  def has_error?
    return self.cm_error.present?
  end
  
  #returns the day of the agenda entry, 1 for the first day, 2 for the second day, ...
  def event_day
    return ((self.start_time - event.start_date + event.start_date.hour.hours)/86400).floor + 1
  end
  
  
  def parse_embedded_video
    Nokogiri.parse embedded_video
  end

  def embedded_video_attribute(a)
    parse_embedded_video.xpath("//@#{ a }").first.try(:value)
  end

  def get_src_from_embed
    embedded_video_attribute("src")
  end

   def get_background_from_embed
    get_src_from_embed &&
    query = URI.parse(get_src_from_embed).query &&
    CGI.parse(query)["image"].try(:first)
  end

  def is_happening_now?
    return start_time.past? && end_time.future?    
  end
    
  def generate_uid
     
     Time.now.strftime("%Y%m%d%H%M%S").to_s + (1..18).collect { (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }.join.to_s.downcase 
    
  end

  authorization_delegate(:event,:as => :content)
  authorization_delegate(:space,:as => :content)
  
  include ConferenceManager::Support::AgendaEntry
end
