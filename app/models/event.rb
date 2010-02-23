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



class Event < ActiveRecord::Base
  
  belongs_to :space
  belongs_to :author, :polymorphic => true
  has_many :posts
  has_many :participants
  has_many :event_invitations, :dependent => :destroy
  has_many :attachments, :dependent => :destroy
  has_one :agenda, :dependent => :destroy
  
  has_logo :class_name => "EventLogo"
  has_permalink :name, :update=>true
  
  include EventToPdf
  
  acts_as_resource :per_page => 10, :param => :permalink
  acts_as_content :reflection => :space
  acts_as_taggable
  acts_as_stage
  acts_as_container :content => :agenda
  alias_attribute :title, :name
  validates_presence_of :name, :start_date , :end_date,
                          :message => "must be specified"
  
  # Attributes for jQuery selectors
  attr_accessor :end_hour
  attr_accessor :mails
  attr_accessor :ids
  attr_accessor :notification_ids
  attr_accessor :invite_msg
  attr_accessor :external_streaming_url 
  
  #Attibutes for Conference Manager
  attr_accessor :web_interface
  attr_accessor :isabel_interface
  attr_accessor :sip_interface
  #Attributes for ConferenceManager video display
  attr_accessor :web_width
  attr_accessor :web_heigth
  attr_accessor :player_width
  attr_accessor :player_height
  attr_accessor :editor_width
  attr_accessor :editor_height
  attr_accessor :streaming_width
  attr_accessor :streaming_height
  
  is_indexed :fields => ['name','description','place','start_date','end_date', 'space_id'],
             :include =>[{:class_name => 'Tag',
                          :field => 'name',
                          :as => 'tags',
                          :association_sql => "LEFT OUTER JOIN taggings ON (events.`id` = taggings.`taggable_id` AND taggings.`taggable_type` = 'Event') LEFT OUTER JOIN tags ON (tags.`id` = taggings.`tag_id`)"},
  {:class_name => 'User',
                               :field => 'login',
                               :as => 'login_user',
                               :association_sql => "LEFT OUTER JOIN users ON (events.`author_id` = users.`id` AND events.`author_type` = 'User') "}
  ]
  
  VC_MODE = [:in_person, :meeting, :teleconference]

  validate_on_create do |event|
   if event.start_date.to_date.past?
     event.errors.add_to_base(I18n.t('event.error.date_past'))
   end
   if (event.vc_mode == Event::VC_MODE.index(:meeting)) || ( event.vc_mode == Event::VC_MODE.index(:teleconference))
      mode = ""
      if event.vc_mode == Event::VC_MODE.index(:meeting)
        mode = "meeting"
      elsif event.vc_mode == Event::VC_MODE.index(:teleconference)
          mode = "conference"
      end 
      cm_e = ConferenceManager::Event.new(:name=> event.name, :mode =>mode, :enable_web => event.web_interface , :enable_isabel => event.isabel_interface, :enable_sip => event.sip_interface, :path => "attachments/conferences/#{event.permalink}")
      begin 
       cm_e.save
       event.cm_event_id = cm_e.id
     rescue StandardError =>e
       event.errors.add_to_base(e.to_s)
      end        
    end  
  end
  
  validate_on_update do |event|
    if (event.vc_mode == Event::VC_MODE.index(:meeting)) || (event.vc_mode == Event::VC_MODE.index(:teleconference))
      mode = ""
      if event.vc_mode == Event::VC_MODE.index(:meeting)
        mode = "meeting"
      elsif event.vc_mode == Event::VC_MODE.index(:teleconference)
          mode = "conference"
      end    
      my_params = {:name=> event.name, :mode =>mode, :enable_web => event.web_interface , :enable_isabel =>event.isabel_interface, :enable_sip => event.sip_interface,:path => "attachments/conferences/#{event.permalink}" }
      cm_event = event.cm_event
      cm_event.load(my_params)  
      begin
        cm_event.save
      rescue  StandardError =>e
        event.errors.add_to_base(e.to_s)  
      end
    end  
  end
  
  before_destroy do |event|
    #Delete event in conference Manager
    if (event.vc_mode == Event::VC_MODE.index(:meeting)) || (event.vc_mode == Event::VC_MODE.index(:teleconference))
      begin
        cm_event = ConferenceManager::Event.find(event.cm_event_id)
        cm_event.destroy  
      rescue => e
        event.errors.add_to_base(I18n.t('event.error.delete'))  
        false
      end
    end
  end
 
  after_create do |event|
    #create an empty agenda
    event.agenda = Agenda.create
    #create a directory to save attachments
    FileUtils.mkdir_p("#{RAILS_ROOT}/attachments/conferences/#{event.permalink}") 
  end
  
  after_save do |event|
    if event.mails
      #NOT ANY MORE: first of all we remove the emails that already has an invitation for this event (not to spam them)
      #mails_to_invite = event.mails.split(/[\r,]/).map(&:strip) - event.event_invitations.map{|ei| ei.email}
      mails_to_invite = event.mails.split(/[\r,]/).map(&:strip)
      mails_to_invite.map { |email|      
        params =  {:role_id => Role.find_by_name("User").id.to_s, :email => email, :event => event, :comment => event.invite_msg}
        i = event.space.event_invitations.build params
        i.introducer = event.author
        i
      }.each(&:save)
    end
    if event.ids
      event.ids.map { |user_id|
        user = User.find(user_id)
        params = {:role_id => Role.find_by_name("User").id.to_s, :email => user.email, :event => event, :comment => event.invite_msg}
        i = event.space.event_invitations.build params
        i.introducer = event.author
        i
      }.each(&:save)
    end
    if event.notification_ids
      event.notification_ids.each { |user_id|
        user = User.find(user_id)
        params = {:event => event, :email => user.email, :sender_login => event.author.login, :receiver_login => user.login, :comment => event.notify_msg}
        n = EventNotification.build params
        Informer.deliver_event_notification(n)
      }
    end
  end
  
  def author
    User.find_with_disabled(author_id)
  end
  
  def space
    Space.find_with_disabled(space_id)
  end      
  
  def organizers
    if actors.size == 0
      ar = Array.new
      ar << author
      return ar
    end
    actors
  end
  
   #return the number of days of this event duration
  def days
    (end_date.to_date - start_date.to_date).to_i     
  end
  
  #returns the day of the agenda entry, 0 for the first day, 1 for the second day, ...
  def day_for(agenda_entry)
    return agenda_entry.start_time.to_date - start_date.to_date
  end
  
  #returns the hour of the last agenda_entry
  def last_hour_for_day(day)
    ordered_entries = agenda.agenda_entries_for_day(day).sort{|x,y| x.end_time <=> y.end_time }
    unless ordered_entries.empty?
      ordered_entries.last.end_time
    else
      if (start_date + day.days).day == Time.now.day
        Time.now
      else
        self.start_date + day.days + 9.hour
      end  
    end  
  end
  
  def entries_ordered_by_date
    agenda.agenda_entries.sort{|x,y| x.end_time <=> y.end_time}  
  end
  
  def syncronize_date
     self.start_date = entries_ordered_by_date.first.start_time
     self.end_date = entries_ordered_by_date.last.end_time
  end
    
    
  #method to know if this event is happening now
  def is_happening_now?
     return !start_date.future? && end_date.future?
  end
  
  #method to know if an event happens in the future
  def future?
    return start_date.future?    
  end
  
  #method to know if an event happens in the past
  def past?
    return end_date.past?
  end
  
  def get_attachments
    return Attachment.find_all_by_event_id(id)
  end
  
  #method to get the starting date of an event in the correct format
  #the problem is that the starting hour comes from the agenda
  def get_formatted_date
    if agenda.present? && agenda.agenda_entries.count>0
      first_entry = agenda.agenda_entries.sort_by{|x| x.start_time}[0]
      #check that the entry is the first day
      if first_entry.start_time > start_date && first_entry.start_time < start_date + 1.day
        return I18n::localize(first_entry.start_time, :format => "%A, %d %b %Y") + " " + I18n::translate('date.at') + " " + first_entry.start_time.strftime("%H:%M") + " (GMT " + Time.zone.formatted_offset + ")"
      else
        return I18n::localize(start_date.to_date, :format => "%A, %d %b %Y")
      end
    end
    return I18n::localize(start_date.to_date, :format => "%A, %d %b %Y")
  end
  
  
  #method to get the starting hour of an event in the correct format
  #the problem is that the starting hour comes from the agenda
  def get_formatted_hour
    if agenda.present? && agenda.agenda_entries.count>0
      first_entry = agenda.agenda_entries.sort_by{|x| x.start_time}[0]
      #check that the entry is the first day
      if first_entry.start_time > start_date && first_entry.start_time < start_date + 1.day
        return first_entry.start_time.strftime("%H:%M")
      else
        return ""
      end
    end
    return ""
  end
  
  
  def validate
    if self.start_date.nil? || self.end_date.nil? 
      errors.add_to_base(I18n.t('event.error.omit_date'))
    else
      unless self.start_date < self.end_date
        errors.add_to_base(I18n.t('event.error.dates1'))
      end  
    end
    if self.marte_event? && ! self.marte_room?
      #check connectivity with Marte
      begin
        MarteRoom.find(:all)
      rescue => e
        errors.add_to_base(I18n.t('event.error.marte'))
      end
    end
    #    unless self.start_date.future? 
    #      errors.add_to_base("The event start date should be a future date  ")
    #    end
  end
  
  after_save do |event|
    if event.marte_event? && ! event.marte_room? && !event.marte_room_changed?
      mr = begin
        MarteRoom.create(:name => event.id)
      rescue => e
        logger.warn "Failed to create MarteRoom: #{ e }"
        nil
      end
      
      event.update_attribute(:marte_room, true) if mr
    end
  end
  
  after_destroy do |event|
    
    FileUtils.rm_rf("#{RAILS_ROOT}/attachments/conferences/#{event.permalink}") 
    if event.marte_event? && event.marte_room?
      begin
        MarteRoom.find(event.id).destroy
      rescue
      end
    end     
  end
  
  def cm_event?
    cm_event.present?
  end
  
  def cm_event
    begin
      @cm_event ||= ConferenceManager::Event.find(self.cm_event_id)
    rescue
      nil
    end  
  end
  
  def sip_interface?
      cm_event.try(:enable_sip?)
  end
  
  def isabel_interface?
      cm_event.try(:enable_isabel?)  
  end
  
  def web_interface?
      cm_event.try(:enable_web?)  
  end
  
  def web_url
      cm_event.try(:web_url)
  end
  
  def sip_url
      cm_event.try(:sip_url)
  end
  
  def isabel_url
      cm_event.try(:isabel_url) 
  end
  
  #Return  a String that contains a html with the video of the Isabel Web Gateway
  def web
    begin
      cm_web ||= ConferenceManager::Web.find(:one,:from=>"/events/#{self.cm_event_id}/web")
      cm_web.html
    rescue
      nil
    end
  end
  
  #Return  a String that contains a html with the video player for this conference
  def player
    begin
      cm_player ||= ConferenceManager::Player.find(:one,:from=>"/events/#{self.cm_event_id}/player")
      cm_player.html
    rescue
      nil
    end
  end
  #Return  a String that contains a html with the video editor for this conference
  def editor
    begin
      cm_editor ||= ConferenceManager::Editor.find(:one,:from=>"/events/#{self.cm_event_id}/editor")
      cm_editor.html
    rescue
      nil
    end
  end
  #Return  a String that contains a html with the streaming of this conference
  def streaming
    begin
      cm_streaming ||= ConferenceManager::Streaming.find(:one,:from=>"/events/#{self.cm_event_id}/streaming")
      cm_streaming.html
    rescue
      nil
    end
  end
    
  def get_room_data
    return nil unless marte_event?
    
    begin
      MarteRoom.find(self.id)
    rescue
      update_attribute('marte_room', false) if attributes['marte_room']
      nil
    end
  end
  
  authorizing do |agent, permission|
    if ( permission == :update || permission == :delete ) && author == agent
      true
    end
  end

end