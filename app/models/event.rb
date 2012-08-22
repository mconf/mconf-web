# -*- coding: utf-8 -*-
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
  extend FriendlyId
  friendly_id :name, :use => :slugged, :slug_column => :permalink

  acts_as_resource :per_page => 10, :param => :permalink
  acts_as_content :reflection => :space
  acts_as_taggable
  acts_as_stage
  acts_as_container :contents => [:agenda]
  alias_attribute :title, :name
  validates_presence_of :name

  # Attributes for jQuery selectors
  attr_accessor :end_hour
  attr_accessor :mails
  attr_accessor :ids
  attr_accessor :notification_ids
  attr_accessor :group_invitation_mails
  attr_accessor :invite_msg
  attr_accessor :invit_introducer_id
  attr_accessor :notif_sender_id
  attr_accessor :group_inv_sender_id
  attr_accessor :notify_msg
  attr_accessor :group_invitation_msg
  attr_accessor :external_streaming_url
  attr_accessor :new_organizers
  attr_accessor :invited_registered
  attr_accessor :invited_unregistered

  # For logos
  attr_accessor :default_logo
  attr_accessor :text_logo
  attr_accessor :rand_value
  attr_accessor :logo_rand

  attr_accessor :edit_date_action

  before_validation  :event_validation, :update_logo, :edit_date_actions

  after_save :update_agenda_entries

  def self.within(from, to)
    where("(start_date >= ? AND start_date <= ?) OR (end_date >= ? AND end_date <= ?)", from, to, from, to)
  end

  # Events that are in the future, that have not started yet.
  scope :future, lambda { where("start_date > ?", Time.now) }

  # Events that are either in the future or are running now.
  scope :upcoming, lambda {
    where("events.end_date > ? AND spaces.disabled = ?", Time.now, false).includes(:space).order("start_date")
  }

  RECORDING_TYPE = [:automatic, :manual, :none]
  EXTRA_TIME_FOR_EVENTS_WITH_MANUAL_REC = 1.hour

  def agenda_entries
    self.agenda.agenda_entries
  end

  def update_agenda_entries
    if self.edit_date_action.eql?("move_event")||self.edit_date_action.eql?("start_date")
      agenda_entries.each do |agenda_entry|
        agenda_entry.date_update_action = self.edit_date_action
        if self.edit_date_action.eql?("move_event")
          agenda_entry.start_time = agenda_entry.start_time + @relative_time
          agenda_entry.end_time = agenda_entry.end_time + @relative_time
        end
        agenda_entry.save
      end
    end
  end

  #  def update_date
  #  if self.edit_date_action.eql?("move_event") || self.edit_date_action.eql?("start_date")
  #    self.start_date(1i) = self.start_date
  #  end
  #end

  def event_validation
    if(self.end_date.to_date - self.start_date.to_date > MAX_DAYS)
      self.errors.add(:base, I18n.t('event.error.max_size_excedeed', :max_days => Event::MAX_DAYS))
      return false
    end
    if((self.end_date - self.start_date) < 15.minutes)
      self.errors.add(:base, I18n.t('event.error.too_short'))
      return false
    end
  end

  def edit_date_actions
    if !self.edit_date_action.nil?
      if !self.edit_date_action.eql?("move_event")
        agenda_entries.each do |agenda_entry|
          if (agenda_entry.start_time < self.start_date) or (agenda_entry.end_time > self.end_date)
            self.errors.add(:base, I18n.t('event.move.out_date', :agenda_entry => agenda_entry.title))
            return false
          end
        end
      end
      if self.edit_date_action.eql?("move_event") and self.start_date_changed?
        #@relative_time = self.start_date - self.start_date_was
        #self.end_date = self.end_date + @relative_time
        @relative_time = 0
      elsif self.edit_date_action.eql?("start_date") and self.start_date_changed?
        @relative_time = 0
      elsif self.edit_date_action.eql?("end_date")
        @relative_time = 0
      end
    end
  end

  def update_logo
    return unless (@default_logo.present? and  !@default_logo.eql?(""))
    if @default_logo.present? and  @default_logo.eql?("use_date_logo")
      if logo = self.logo
        logo.destroy
      end
      self.logo = nil
      return true
    end
    img_orig = Magick::Image.read(File.join(PathHelpers.images_full_path, @default_logo)).first
    img_orig = img_orig.scale(256, 256)
    images_path = PathHelpers.images_full_path
    final_path = FileUtils.mkdir_p(File.join(images_path, "tmp/#{@rand_value}"))
    img_orig.write(File.join(images_path, "tmp/#{@rand_value}/temp.jpg"))
    original = File.open(File.join(images_path, "tmp/#{@rand_value}/temp.jpg"))
    # TODO check, was using UploadedTempfile
    #original_tmp = ActionDispatch::Http::UploadedFile.open("default_logo")
    original_tmp = Tempfile.new("default_logo", "#{ Rails.root.to_s}/tmp/")
    original_tmp.write(original.read)
    original_tmp_io = open(original_tmp)
    filename = File.join(images_path, @default_logo)
    (class << original_tmp_io; self; end;).class_eval do
      define_method(:original_filename) { filename.split('/').last }
      define_method(:content_type) { 'image/jpeg' }
      define_method(:size) { File.size(filename) }
    end

    logo = {}
    logo[:media] = original_tmp_io
    #debugger
    logo = self.build_logo(logo)

    images_path = File.join(Rails.root.to_s, "public", "images")
    tmp_path = File.join(images_path, "tmp")
    #debugger

    if @rand_value != nil
      final_path = FileUtils.rm_rf(tmp_path + "/#{@rand_value}")
    end

  end

  VC_MODE = [:in_person, :telemeeting, :teleconference, :teleclass]

  # The vc_mode symbol of this event
  def vc_mode_sym
    VC_MODE[vc_mode]
  end

  # Maximum number of consecutive days for the event
  MAX_DAYS = 5


  validate :validate_method
  def validate_method
    #    if start_date.to_date.past?
    #      errors.add(:base, I18n.t('event.error.date_past'))
    #    end
    #    if self.start_date.nil? || self.end_date.nil?
    #      errors.add(:base, I18n.t('event.error.omit_date'))
    #    else
    unless self.start_date < self.end_date
      errors.add(:base, I18n.t('event.error.dates1'))
    end
    #    end
    if self.marte_event? && ! self.marte_room?
      #check connectivity with Marte
      begin
        MarteRoom.find(:all)
      rescue => e
        errors.add(:base, I18n.t('event.error.marte'))
      end
    end
    #    unless self.start_date.future?
    #      errors.add(:base, "The event start date should be a future date  ")
    #    end
  end

  after_create do |event|
    #create an empty agenda
    event.agenda = Agenda.create
    #create a directory to save attachments
    FileUtils.mkdir_p("#{Rails.root.to_s}/attachments/conferences/#{event.permalink}")
    if event.author.present?
      event.stage_performances.create! :agent => event.author, :role  => Event.role("Organizer")
    end
  end

  after_save do |event|
    if event.mails
      mails_to_invite = event.mails.split(/[\r,]/).map(&:strip)
      mails_to_invite.map { |email|
        params =  {:role_id => Role.find_by_name("Invitedevent").id.to_s, :email => email, :comment => event.invite_msg}
        i = event.invitations.build params
        i.introducer = User.find(event.invit_introducer_id)
        i
      }.each(&:save)
    end
    if event.ids
      event.ids.map { |user_id|
        user = User.find(user_id)
        params = {:role_id => Role.find_by_name("Invitedevent").id.to_s, :email => user.email, :comment => event.invite_msg}
        i = event.invitations.build params
        i.introducer = User.find(event.invit_introducer_id)
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
    if event.group_invitation_mails
      if event.group_invitation_msg # TODO: not the best way to do it, see events/_group_invitation
        event.group_invitation_msg = event.group_invitation_msg.html_safe
      end
      event.group_invitation_mails.split(',').each { |mail|
        Informer.deliver_event_group_invitation(event,mail)
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

    if event.new_organizers.present?

      #first we delete the old ones if there were some (this is for the update operation that creates new performances in the event)
      past_performances = event.stage_performances.find(:all, :conditions => {:role_id => Event.role("Organizer")})
      past_organizers = past_performances.map(&:agent).map(&:login)

      invited_performances = event.stage_performances.find(:all, :conditions => {:role_id => Event.role("Invitedevent")})

      # we add those organizers that were not past organizers
       (event.new_organizers - past_organizers).each do |login|

        # we remove the previous Invited role in the event if it exists
        invited_performances.each do |p|
          if (p.role == Event.role("Invitedevent")) && (p.agent.login == login)
            p.destroy
          end
        end

        event.stage_performances.create! :agent => User.find_by_login(login), :role  => Event.role("Organizer")
      end

      # we remove those organizers that are not organizers any more
      past_performances.select{ |p| (past_organizers - event.new_organizers).include?(p.agent.login)}.map(&:destroy)
    end

    if event.recording_type_changed?
      if event.recording_type_was == Event::RECORDING_TYPE.index(:automatic)
        #changed FROM automatic, update all the agenda_entries with recording=false to the CM
        event.agenda.agenda_entries.each do |entry|
          entry.update_attributes(:cm_recording=> false)
        end
      end
      if event.recording_type == Event::RECORDING_TYPE.index(:automatic)
        #changed TO automatic, update all the agenda_entries with recording=true to the CM
        event.agenda.agenda_entries.each do |entry|
          entry.update_attributes(:cm_recording=> true)
        end
      end
    end

  end


  after_destroy do |event|
    FileUtils.rm_rf("#{Rails.root.to_s}/attachments/conferences/#{event.permalink}")
    FileUtils.rm_rf("#{Rails.root.to_s}/public/pdf/#{event.permalink}")

    if event.marte_event? && event.marte_room?
      begin
        MarteRoom.find(event.id).destroy
      rescue
      end
    end
  end


  def author
    unless author_id.blank?
      return User.find_with_disabled(author_id)
    else
      return nil
    end
  end


  def videos
    self.agenda.agenda_entries.select{|ae| ae.past? & ae.recording?}
  end


  def space
    space_id.present? ?
    Space.find_with_disabled(space_id) :
    nil
  end


  def organizers
    actors(:role => "Organizer")
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
  #def syncronize_date
  #   self.update_attributes({:start_date => self.agenda.recalculate_start_time,
  #                           :end_date => self.agenda.recalculate_end_time})
  #end


  #method to know if any of the agenda_entry of the event has streaming
  def has_streaming?
    if is_in_person?
      if other_streaming_url== nil || other_streaming_url==""
        return false
      else
        return true
      end
    else
      begin
        agenda.agenda_entries.each do |entry|
          return true if entry.cm_session.streaming?
        end
        false
      rescue
        nil
      end
    end
  end

  #method to know if any of the agenda_entry of the event has streaming
  def has_participation?
    if is_in_person?
      if other_participation_url== nil || other_participation_url==""
        return false
      else
        return true
      end
    else
      begin
        cm_event.enable_web?
      rescue
        nil
      end
    end
  end


  #method to know everything about streaming
  def show_streaming?
    is_happening_now? || is_in_person?
  end

  #method to know if we need to paint the participation button
  def show_participation?
    is_happening_now? || is_in_person?
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
    elsif uses_conference_manager? && recording_type == RECORDING_TYPE.index(:manual)
      if has_date? && start_date.past? && (end_date + EXTRA_TIME_FOR_EVENTS_WITH_MANUAL_REC).future?
        true
      end
    else
      return false
    end
  end


  #method to know if we show the recording box in the event to record the event
  def show_recording_box?
    if is_happening_now?
      return true
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
    I18n::localize(start_date, :format => "%A, %d %b %Y #{I18n::translate('date.at')} %H:%M. #{get_formatted_timezone}") :
    I18n::t('date.undefined')
  end

  def get_formatted_timezone
    has_date? ?
      "#{I18n::t('timezone.one')}: #{Time.zone.name} (#{start_date.zone}, GMT #{start_date.formatted_offset})" :
    I18n::t('date.undefined')
  end

  #method to get the starting hour of an event in the correct format
  def get_formatted_hour
    has_date? ? start_date.strftime("%H:%M") : I18n::t('date.undefined')
  end


  def is_in_person?
    vc_mode_sym == :in_person
  end

  def is_virtual?
    ! is_in_person?
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
    if ( permission == :update || permission == :delete || permission == [:update, :content] || permission == [:delete, :content] ) && author == agent
      true
    end
  end

  authorizing do |agent, permission|
    if permission == :read && agent.is_a?(XmppServer)
      true
    end
  end

  #method to know if a scorm file needs to be generated
  def scorm_needs_generate
    isFile = File.exist?("#{Rails.root.to_s}/public/scorm/#{permalink}.zip")

    if !(isFile) or !(generate_scorm_at) or generate_scorm_at < agenda.updated_at
      Event.record_timestamps=false
      update_attribute(:generate_scorm_at, Time.now)
      Event.record_timestamps=true
      return true
    else
      return false
    end
  end

  #method to generate the xml representing the scorm manifest
  def generate_scorm_manifest_in_zip(zos)
    video_entries = self.videos
    myxml = Builder::XmlMarkup.new(:indent => 2)
    myxml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
    myxml.manifest('xsi:schemaLocation'=>"http://www.imsproject.org/xsd/imscp_rootv1p1p2 imscp_rootv1p1p2.xsd http://www.imsglobal.org/xsd/imsmd_rootv1p2p1 imsmd_rootv1p2p1.xsd http://www.adlnet.org/xsd/adlcp_rootv1p2 adlcp_rootv1p2.xsd", 'identifier'=>"MANIFEST-A2F3004F6186AC9480285D4AEDCD6BAF", 'xmlns:adlcp'=>"http://www.adlnet.org/xsd/adlcp_rootv1p2", 'xmlns:xsi'=>"http://www.w3.org/2001/XMLSchema-instance", 'xmlns:imsmd'=>"http://www.imsglobal.org/xsd/imsmd_rootv1p2p1", 'xmlns'=>"http://www.imsproject.org/xsd/imscp_rootv1p1p2") do
      myxml.organizations('default'=>Event.identifier_for("ITEM" + video_entries[0].title)) do
        myxml.organization('identifier'=>Event.identifier_for("ITEM" + video_entries[0].title), 'structure'=>"hierarchical") do
          ind = 1 if video_entries.size > 1
          video_entries.each do |entry|
            myxml.item('identifier'=>Event.identifier_for("ITEM" + Event.remove_accents(entry.title)), 'isvisible'=>"true") do
              if video_entries.size > 1
                suffix = " - " + I18n::t('session.one')  + " " + ind.to_s
                ind = ind + 1
              else
                suffix = ""
              end
              myxml.title(self.name + suffix)
              myxml.item('identifier'=>Event.identifier_for("ITEM-sub" + Event.remove_accents(entry.title)), 'identifierref'=>Event.identifier_for("RES" + Event.remove_accents(entry.title)), 'isvisible'=>"true") do
                myxml.title(entry.title)
              end
              entry.attachments.each  do |at|
                myxml.item('identifier'=>Event.identifier_for("ITEM" + Event.remove_accents(at.filename)), 'identifierref'=>Event.identifier_for("RES" + Event.remove_accents(at.filename)), 'isvisible'=>"true") do
                  myxml.title(at.filename)
                end
              end
            end
          end
        end
      end
      myxml.resources do
        video_entries.each do |entry|
          myxml.resource('identifier'=>Event.identifier_for("RES" + Event.remove_accents(entry.title)), 'type'=>"text/html", 'href'=>Event.remove_accents(entry.title) + ".html", 'adlcp:scormtype'=>"sco") do
            myxml.file('href'=> Event.remove_accents(entry.title) + ".html")
          end
          entry.attachments.each  do |at|
            myxml.resource('identifier'=>Event.identifier_for("RES" + Event.remove_accents(at.filename)), 'type'=>"webcontent", 'href'=>Event.remove_accents(at.filename)) do
              myxml.file('href'=>Event.remove_accents(at.filename))
            end
          end
        end
        myxml.resource('identifier'=>Event.identifier_for("RES" + "-scorm.css"), 'type'=>"text/css", 'href'=>"scorm.css", 'adlcp:scormtype'=>"sco") do
          myxml.file('href'=> "scorm.css")
        end
      end
    end
    zos.put_next_entry("imsmanifest.xml")
    zos.print myxml.target!()
    #File.open("#{Rails.root.to_s}/public/scorm/#{event.permalink}/imsmanifest.xml", "wb") { |f| f << myxml }
  end


  def self.identifier_for(title)
    Base64.b64encode(title).chomp.gsub(/\n/,'')
  end


  def self.remove_accents(str)
    accents = {
      ['á','à','â','ä','ã'] => 'a',
      ['Ã','Ä','Â','À'] => 'A',
      ['é','è','ê','ë'] => 'e',
      ['Ë','É','È','Ê'] => 'E',
      ['í','ì','î','ï'] => 'i',
      ['Î','Ì'] => 'I',
      ['ó','ò','ô','ö','õ'] => 'o',
      ['Õ','Ö','Ô','Ò','Ó'] => 'O',
      ['ú','ù','û','ü'] => 'u',
      ['Ú','Û','Ù','Ü'] => 'U',
      ['ç'] => 'c', ['Ç'] => 'C',
      ['ñ'] => 'n', ['Ñ'] => 'N'
    }
    accents.each do |ac,rep|
      ac.each do |s|
        str = str.gsub(s, rep)
      end
    end
    str = str.gsub(/[^a-zA-Z0-9\. ]/,"")
    str = str.gsub(/[ ]+/," ")
    str = str.gsub(/ /,"-")
    #str = str.downcase
  end

  def unique_pageviews
    # Use only the canonical aggregated url of the event (all views have been previously added here in the rake task)
    search_string = '/spaces/' + self.space.permalink + '/events/'+ self.permalink
    corresponding_statistics = Statistic.find(:all, :conditions => ['url LIKE ?', search_string])
    if corresponding_statistics.size == 0
      return 0
    elsif corresponding_statistics.size == 1
      return corresponding_statistics.first.unique_pageviews
    elsif corresponding_statistics.size > 1
      logger.warn "Incorrectly parsed statistics:"
      logger.warn "  Search string: \"#{search_string}\""
      logger.warn "  Registries found: #{corresponding_statistics.size}"
      return corresponding_statistics.first.unique_pageviews
    end
  end

  include ConferenceManager::Support::Event
end
