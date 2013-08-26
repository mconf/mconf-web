# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class Event < ActiveRecord::Base

  belongs_to :space
  belongs_to :author, :class_name => 'User'

  has_many :posts, :dependent => :destroy
  has_many :participants, :dependent => :destroy
  has_many :attachments, :dependent => :destroy

  has_many :invitations, :class_name => "JoinRequest", :foreign_key => "group_id",
           :conditions => { :join_requests => {:group_type => 'Event'} }

  has_many :permissions, :foreign_key => "subject_id",
           :conditions => { :permissions => {:subject_type => 'Event'} }

  extend FriendlyId
  friendly_id :name, :use => :slugged, :slug_column => :permalink

  acts_as_resource :per_page => 10, :param => :permalink
  acts_as_content :reflection => :space
  acts_as_taggable
  alias_attribute :title, :name
  validates_presence_of :name

  # Attributes for jQuery selectors
  attr_accessor :mails
  attr_accessor :ids
  attr_accessor :notification_ids
  attr_accessor :invite_msg
  attr_accessor :invit_introducer_id
  attr_accessor :notif_sender_id
  attr_accessor :notify_msg
  attr_accessor :edit_date_action

  before_validation  :event_validation, :edit_date_actions

  def self.within(from, to)
    where("(start_date >= ? AND start_date <= ?) OR (end_date >= ? AND end_date <= ?)", from, to, from, to)
  end

  # Events that are in the future, that have not started yet.
  scope :future, lambda { where("start_date > ?", Time.now) }

  # Events that are either in the future or are running now.
  scope :upcoming, lambda {
    where("events.end_date > ? AND spaces.disabled = ?", Time.now, false).includes(:space).order("start_date")
  }

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

  VC_MODE = [:in_person, :telemeeting, :teleconference, :teleclass]

  # The vc_mode symbol of this event
  def vc_mode_sym
    VC_MODE[vc_mode]
  end

  # Maximum number of consecutive days for the event
  MAX_DAYS = 5

  validate :validate_method
  def validate_method
    unless self.start_date < self.end_date
      errors.add(:base, I18n.t('event.error.dates1'))
    end
  end

  after_create do |event|
    #create a directory to save attachments
    FileUtils.mkdir_p("#{Rails.root.to_s}/attachments/conferences/#{event.permalink}")
    if event.author.present?
      add_organizer! event.author
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
  end

  after_destroy do |event|
    FileUtils.rm_rf("#{Rails.root.to_s}/attachments/conferences/#{event.permalink}")
    FileUtils.rm_rf("#{Rails.root.to_s}/public/pdf/#{event.permalink}")
  end

  def author
    unless author_id.blank?
      return User.find_by_id_with_disabled(author_id)
    else
      return nil
    end
  end

  def space
    space_id.present? ?
    Space.find_with_disabled(space_id) :
    nil
  end

  def organizers
    permissions.where(:role_id => Role.find_by_name_and_stage_type('Organizer', 'Event')).map(&:user)
  end

  #return the number of days of this event duration
  def days
    if has_date?
     (end_date.to_date - start_date.to_date).to_i + 1
    else
      return 0
    end
  end

  #method to know if this event is happening now
  def is_happening_now?
    #first we check if start date is past and end date is future
    if has_date? && start_date.past? && end_date.future?
      true
    else
      return false
    end
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

  private

  def add_organizer! user
    p = Permission.new
    p.user = user
    p.subject = self
    p.role = Role.find_by_name_and_stage_type('Organizer', 'Event')
    p.save!
  end

end
