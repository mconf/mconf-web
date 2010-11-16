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
  attr_accessor :author, :duration, :date_update_action
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
      
      if (self.start_time < self.agenda.event.start_date) or (self.end_time > self.agenda.event.end_date) 
        self.errors.add_to_base I18n.t('event.move.out_date', :agenda_entry => agenda_entry.title)
        return false
      end
      
      self.agenda.contents_for_day(self.event_day).each do |content|
        next if ( (content.class == AgendaEntry) && (content.id == self.id) )
        
        if (self.start_time <= content.start_time) && (self.end_time >= content.end_time)
          unless (content.start_time == content.end_time) && ((content.start_time == self.start_time) || (content.start_time == self.end_time))
            self.errors.add_to_base(I18n.t('agenda.entry.error.coinciding_times'))
            return
          end
        elsif (content.start_time..content.end_time) === self.start_time
          unless (self.start_time == content.end_time) || ((self.start_time == content.start_time) && (self.start_time == self.end_time)) then
            self.errors.add_to_base(I18n.t('agenda.entry.error.coinciding_times'))
            return
          end
        elsif (content.start_time..content.end_time) === self.end_time
          unless (self.end_time == content.start_time) || ((self.end_time == content.end_time) && (self.end_time == self.start_time)) then
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
    FileUtils.mkdir_p("#{RAILS_ROOT}/attachments/conferences/#{entry.event.permalink}/#{entry.title.gsub(" ","_")}")
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
    entry.event.agenda.touch
  end
  
  
  after_destroy do |entry|  
    if entry.title.present?
      FileUtils.rm_rf("#{RAILS_ROOT}/attachments/conferences/#{entry.event.permalink}/#{entry.title.gsub(" ","_")}")
    end
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
    if !event.uses_conference_manager?  #manual mode
      if embedded_video.present? && embedded_video != ""
        return true
      else 
        return false
      end
    else #automatic mode
      if discard_automatic_video
        if embedded_video.present? && embedded_video != ""
          return true
        else 
          return false
        end
      else
        cm_recording?
      end
    end
  end
  
  named_scope :with_recording, lambda {
    { :conditions => [ "embedded_video is not ? or cm_recording = ?",
      nil, true ] }
  }
  
  def streaming?
    cm_streaming?
  end
  
  def thumbnail
    video_thumbnail.present? ?
    video_thumbnail :
      "default_background.jpg"
  end
  
  #returns the player with the specified width and height
  #or the embedded_video if the entry has one
  def video_player(width, height)
    embedded_video || player(width, height)
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
   (get_src_from_embed) && (query = URI.parse(get_src_from_embed).query) && (CGI.parse(query)["image"].try(:first))
  end
  
  def is_happening_now?
    return start_time.past? && end_time.future?    
  end
  
  def generate_uid
    
    Time.now.strftime("%Y%m%d%H%M%S").to_s + (1..18).collect { (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }.join.to_s.downcase 
    
  end
  
=begin
  def to_json
    result = {}
    result[:title] = title
    result[:start] = "new Date(#{start_time.strftime "%y"},#{start_time.strftime "%m"},#{start_time.strftime "%d"},#{start_time.strftime "%H"},#{start_time.strftime "%M"})"
    result[:end] = "new Date(#{end_time.strftime "%y"},#{end_time.strftime "%m"},#{end_time.strftime "%d"},#{end_time.strftime "%H"},#{end_time.strftime "%M"})"
    result.to_json
  end
=end
  
  def video_unique_pageviews
    # Use only the canonical aggregated url of the video (all views have been previously added here in the rake task)
    corresponding_statistics = Statistic.find(:all, :conditions => ['url LIKE ?', '/spaces/' + self.space.permalink + '/videos/'+ self.id.to_s])
    if corresponding_statistics.size == 0
      return 0
    elsif corresponding_statistics.size == 1
      return corresponding_statistics.first.unique_pageviews
    elsif corresponding_statistics.size > 1
      raise "Incorrectly parsed statistics"
    end
  end
  
  authorization_delegate(:event,:as => :content)
  authorization_delegate(:space,:as => :content)
  
  include ConferenceManager::Support::AgendaEntry
  
  def to_fullcalendar_json
      "{
         title: \"#{title ? sanitize_for_fullcalendar(title) : ''}\",
         start: new Date(#{start_time.strftime "%Y"},#{start_time.month-1},#{start_time.strftime "%d"},#{start_time.strftime "%H"},#{start_time.strftime "%M"}),
         end: new Date(#{end_time.strftime "%Y"},#{end_time.month-1},#{end_time.strftime "%d"},#{end_time.strftime "%H"},#{end_time.strftime "%M"}),
  allDay: false,
  id: #{id},
  description: \"#{description ? sanitize_for_fullcalendar(description) : ''}\",
         speakers: \"#{sanitize_for_fullcalendar(complete_speakers)}\",
         supertitle: \"#{divider ? sanitize_for_fullcalendar(divider) : ''}\"
       }"  
end

private

def sanitize_for_fullcalendar(string) 
  string.gsub("\r","").gsub("\n","<br />").gsub(/["]/, '\'')
end

def complete_speakers
 (actors + [speakers]).compact.map{ |a|
    a.is_a?(User) ? 
    a.name :
     (a=="" ? nil : a)
  }.compact.join(", ")
end

end