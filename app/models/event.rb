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
  has_many :participants, :dependent => :destroy
  has_many :attachments, :dependent => :destroy
  has_one :agenda, :dependent => :destroy
  
  has_logo :class_name => "EventLogo"
  has_permalink :name, :update=>true
  
  include EventToPdf
  include EventToIcs
  
  acts_as_resource :per_page => 10, :param => :permalink
  acts_as_content :reflection => :space
  acts_as_taggable
  acts_as_stage
  acts_as_container :contents => [:agenda]
  alias_attribute :title, :name
  validates_presence_of :name,
                        :message => "must be specified"
  
  # Attributes for jQuery selectors
  attr_accessor :end_hour
  attr_accessor :mails
  attr_accessor :ids
  attr_accessor :notification_ids
  attr_accessor :invite_msg
  attr_accessor :notify_msg
  attr_accessor :external_streaming_url 
  
  #Attibutes for Conference Manager
  attr_accessor :web_interface
  attr_accessor :isabel_interface
  attr_accessor :sip_interface
    
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


   def validate
#    if start_date.to_date.past?
#      errors.add_to_base(I18n.t('event.error.date_past'))
#    end
#    if self.start_date.nil? || self.end_date.nil? 
#      errors.add_to_base(I18n.t('event.error.omit_date'))
#    else
#      unless self.start_date < self.end_date
#        errors.add_to_base(I18n.t('event.error.dates1'))
#      end  
#    end
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
  
  
  validate_on_create do |event|
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
      rescue ActiveResource::ResourceNotFound => e
        true  
      else        
        #event.errors.add_to_base(I18n.t('event.error.delete'))  
        true
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
      mails_to_invite = event.mails.split(/[\r,]/).map(&:strip)
      mails_to_invite.map { |email|      
        params =  {:role_id => Role.find_by_name("Invited").id.to_s, :email => email, :comment => event.invite_msg}
        i = event.invitations.build params
        i.introducer = event.author
        i
      }.each(&:save)
    end
    if event.ids
      event.ids.map { |user_id|
        user = User.find(user_id)
        params = {:role_id => Role.find_by_name("Invited").id.to_s, :email => user.email, :comment => event.invite_msg}
        i = event.invitations.build params
        i.introducer = event.author
        i
      }.each(&:save)
    end
    if event.notification_ids
      event.notification_ids.each { |participant_id|
        participant = Participant.find(participant_id)
        if event.participants.include? participant
          Informer.deliver_event_notification(event,participant.user)
        end
      }
    end
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
    if has_date?
      (end_date.to_date - start_date.to_date).to_i + 1
    else
      return 0
    end
  end
  
    
  #method to syncronize event start and end time with their agenda real length
  #we have to take into account the timezone, because we are saving the time in the database directly
  def syncronize_date
     self.update_attributes({:start_date => agenda.recalculate_start_time,
                             :end_date => agenda.recalculate_end_time})
  end
  
  
  #method to know if any of the agenda_entry of the event has streaming 
  #(only event associated to one cm_event could have streaming)
  def has_streaming?
    begin
      agenda.agenda_entries.each do |entry|
        return true if entry.cm_session.streaming?
      end
      false 
    rescue
      nil
    end
  end
  
#better the method agenda.has_entries_with_video?
#
#  #method to know if any of the agenda_entry of the event has recording
#  def has_recording?
#    begin
#      agenda.agenda_entries.each do |entry|
#        return true if entry.cm_session.recording?
#      end    
#      false
#    rescue
#      nil
#    end
#  end
    
    
  #method to know if this event is happening now
  def is_happening_now?
     #first we check if start date is past and end date is future
     if has_date? && start_date.past? && end_date.future?
       true      
     else
       return false
     end
  end
    
    
  #method to know if this event has any session now
  def has_session_now?
     get_session_now
  end
  
  def get_session_now
    #first we check if start date is past and end date is future
     if is_happening_now?
       #now we check the sessions
       agenda.agenda_entries.each do |entry|
         return entry if entry.start_time.past? && entry.end_time.future?
       end   
     end
     return nil
  end
  
  #method to know if an event happens in the future
  def future?
    return has_date? && start_date.future?    
  end
  
  
  #method to know if an event happens in the past
  def past?
    return has_date? && end_date.past?
  end
  
  
  def has_date?
    start_date
  end
  
  def get_attachments
    return Attachment.find_all_by_event_id(id)
  end
  
  #method to get the starting date of an event in the correct format
  def get_formatted_date
    has_date? ?
      I18n::localize(start_date, :format => "%A, %d %b %Y #{I18n::translate('date.at')} %H:%M (GMT #{Time.zone.formatted_offset})") :
      I18n::t('date.undefined')       
  end
  
  
  #method to get the starting hour of an event in the correct format
  def get_formatted_hour
    has_date? ? start_date.strftime("%H:%M") : I18n::t('date.undefined')  
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
  
  def is_in_person?
    vc_mode == Event::VC_MODE.index(:in_person)
  end
  
  def is_virtual?
    !is_in_person?
  end
  
  #Return  a String that contains a html with the video of the Isabel Web Gateway
  def web(width, height)
    begin      
      cm_web ||= ConferenceManager::Web.find(:one,:from=>"/events/#{self.cm_event_id}/web",:params =>{:width=>width, :height=>height})
      cm_web.html 
    rescue
      nil
    end
  end
  
  
  def web
    begin
      cm_web ||= ConferenceManager::Web.find(:one,:from=>"/events/#{self.cm_event_id}/web")
      cm_web.html
    rescue
      nil
    end      
  end
  
  
  #Return  a String that contains a html with the video player for this conference
  def player(width,height)
    begin
      cm_player ||= ConferenceManager::Player.find(:one,:from=>"/events/#{self.cm_event_id}/player",:params =>{:width=>width, :height=>height})
      cm_player.html
    rescue
      nil
    end
  end
  
  def player
    begin
      cm_player ||= ConferenceManager::Player.find(:one,:from=>"/events/#{self.cm_event_id}/player")
      cm_player.html
    rescue
      nil
    end
  end
 
 
  def editor(width,height)
    begin
      cm_editor ||= ConferenceManager::Editor.find(:one,:from=>"/events/#{self.cm_event_id}/editor",:params =>{:width=>width, :height=>height})
      cm_editor.html
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
  
  
  def streaming(width,height)
    begin
      cm_streaming ||= ConferenceManager::Streaming.find(:one,:from=>"/events/#{self.cm_event_id}/streaming",:params =>{:width=>width, :height=>height})
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
  
  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.event do
      xml.id         self.id
      xml.public     self.space.public?, :type => "boolean"
      xml.start_date self.start_date,    :type => "datetime"
      xml.end_date   self.end_date,      :type => "datetime"
      xml.place      self.place
      xml.permalink  self.permalink
      xml.name       self.name
    end
  end
  
  authorizing do |agent, permission|
    if ( permission == :update || permission == :delete ) && author == agent
      true
    end
  end

end