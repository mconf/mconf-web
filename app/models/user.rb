# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'devise/encryptors/station_encryptor'
require 'digest/sha1'
class User < ActiveRecord::Base

  ## Devise setup
  # Other available devise modules are:
  # :token_authenticatable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable,
         :encryptable
  # Virtual attribute for authenticating by either username or email
  attr_accessor :login
  # To login with username or email, see: http://goo.gl/zdIZ5
  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      hash = { :value => login.downcase }
      where_clause = ["lower(username) = :value OR lower(email) = :value", hash]
      where(conditions).where(where_clause).first
    else
      where(conditions).first
    end
  end

  attr_accessible :email, :password, :password_confirmation, :remember_me,
                  :login, :username
  # TODO: block :username from being modified after registration
  # attr_accessible :username, :as => :create

  validates :username, :uniqueness => { :case_sensitive => false },
                       :presence => true,
                       :format => /^[A-Za-z0-9\-_]*$/,
                       :length => { :minimum => 1 }
  extend FriendlyId
  friendly_id :username

  def ability
    @ability ||= Abilities.ability_for(self)
  end

  # Returns true if the user is anonymous (not registered)
  def anonymous?
    self.new_record?
  end

  # Returns whether the user can create meetings in the `room`.
  def can_create_meeting?(room)
    if (room.owner_type == "User" && room.owner.id == self.id)
      true
    elsif (room.owner_type == "Space")
      space = Space.find(room.owner.id)
      space.users.include?(self)
    else
      false
    end
  end

###

  apply_simple_captcha

  validates :email, :presence => true, :email => true

  acts_as_taggable :container => false
  acts_as_resource :param => :username

  has_and_belongs_to_many :spaces, :join_table => :permissions,
                          :association_foreign_key => "subject_id",
                          :conditions => { :permissions => {:subject_type => 'Space'} }

  has_many :permissions, :dependent => :destroy
  has_one :profile, :dependent => :destroy
  has_many :events, :as => :author
  has_many :participants, :dependent => :destroy
  has_many :posts, :as => :author, :dependent => :destroy
  has_many :memberships, :dependent => :destroy
  has_one :bigbluebutton_room, :as => :owner, :dependent => :destroy

  accepts_nested_attributes_for :bigbluebutton_room

  # TODO: see JoinRequestsController#create L50
  attr_accessible :created_at, :updated_at, :activated_at, :disabled
  attr_accessible :captcha, :captcha_key, :authenticate_with_captcha
  attr_accessible :email2, :email3
  attr_accessible :timezone
  attr_accessible :expanded_post
  attr_accessible :notification
  attr_accessible :special_event_id
  attr_accessible :superuser
  attr_accessible :receive_digest
  attr_accessor :special_event_id

  # Full name must go to the profile, but it is provided by the user when
  # signing up so we have to cache it until the profile is created
  attr_accessor :_full_name
  attr_accessible :_full_name

  # BigbluebuttonRoom requires an identifier with 3 chars generated from :name
  # So we'll require :_full_name and :username to have length >= 3
  # TODO: review, see issue #737
  validates :_full_name, :presence => true, :length => { :minimum => 3 }, :on => :create

  after_create :create_webconf_room
  after_update :update_webconf_room

  default_scope :conditions => {:disabled => false}

  # constants for the notification attribute
  NOTIFICATION_VIA_EMAIL = 1
  NOTIFICATION_VIA_PM = 2

  # constants for the receive_digest attribute
  RECEIVE_DIGEST_NEVER = 0
  RECEIVE_DIGEST_DAILY = 1
  RECEIVE_DIGEST_WEEKLY = 2

  # Profile
  def profile!
    if profile.blank?
      self.create_profile
    else
      profile
    end
  end

  def create_webconf_room
    params = {
      :owner => self,
      :server => BigbluebuttonServer.first,
      :param => self.username,
      :name => self.username,
      :logout_url => "/feedback/webconf/",
      :moderator_password => SecureRandom.hex(4),
      :attendee_password => SecureRandom.hex(4)
    }
    create_bigbluebutton_room(params)
  end

  def update_webconf_room
    if self.username_changed?
      params = {
        :param => self.username,
        :name => self.username
      }
      bigbluebutton_room.update_attributes(params)
    end
  end

  delegate :full_name, :logo, :organization, :city, :country, :logo_image, :logo_image_url, :to => :profile!
  alias_attribute :name, :full_name
  alias_attribute :title, :full_name
  alias_attribute :permalink, :username

  # Full location: city + country
  def location
    if !self.city.blank? && !self.country.blank?
      [ self.city, self.country ].join(', ')
    elsif !self.city.blank?
      self.city
    elsif !self.country.blank?
      self.country
    else
      ""
    end
  end


  after_create do |user|
    user.create_profile :full_name => user._full_name

    # If user joined for participating in an event,
    # create a join request and add him to the space
    if user.special_event_id
      event = Event.find_by_id(user.special_event_id)

      if event && event.space.public
        event.space.add_member!(user, Role.default_role.name)

        j = JoinRequest.create(
          :email => user.email,
          :request_type => 'request',
          :group_type => 'Event',
          :group_id => event.id,
          :role_id => Role.default_role.id,
          :comment => '-',
          :candidate_id => user.id,
          :accepted => true
          )
      end
    end

    # Checking if we have to join a space and/or event
    invites = JoinRequest.where :email => user.email
    invites.each do |invite|

      if invite.event?
        part_aux = Participant.new
        part_aux.email = user.email
        part_aux.user_id = user.id
        part_aux.event_id = invite.group_id
        part_aux.attend = true
        part_aux.save!
      elsif invite.space?
        space.add_member!(user)
      end
    end

  end

  def self.find_with_disabled *args
    self.with_exclusive_scope { find_by_username(*args) }
  end

  def self.find_by_id_with_disabled *args
    self.with_exclusive_scope { find(*args) }
  end

  def <=>(user)
    self.username <=> user.username
  end

  def other_public_spaces
    Space.public.all(:order => :name) - spaces
  end

  def user_count
    users.size
  end

  def disable
    self.update_attribute(:disabled,true)
    self.permissions.each(&:destroy)
  end

  def enable
    self.update_attribute(:disabled,false)
  end

  # Use profile.logo for users logo when present
  def logo_image_path_with_logo(options = {})
    logo.present? ?
      logo.logo_image_path(options) :
      logo_image_path_without_logo(options)
  end
  alias_method_chain :logo_image_path, :logo

  def fellows(name=nil, limit=nil)
    limit = limit || 5            # default to 5
    limit = 50 if limit.to_i > 50 # no more than 50

    # ids of unique users that belong to the same stages
    ids = Permission.where(:subject_id => self.spaces).select(:user_id).uniq.map(&:user_id)

    # filters and selects the users
    query = User.where(:id => ids).joins(:profile).where("users.id != ?", self.id)
    query = query.where("profiles.full_name LIKE ?", "%#{name}%") unless name.nil?
    query.limit(limit).order("profiles.full_name").includes(:profile)
  end

  def public_fellows
    fellows
  end

  def private_fellows
    spaces.select{|x| x.public == false}.map(&:users).flatten.compact.uniq.sort{ |x, y| x.name <=> y.name }
  end

  def has_events_in_this_space?(space)
    !events.select{|ev| ev.space==space}.empty?
  end

  # Returns an array with all the webconference rooms accessible to this user
  # Includes his own room, the rooms for the spaces he belogs to and the room
  # for all public spaces
  def accessible_rooms
    rooms = BigbluebuttonRoom.where(:owner_type => "User", :owner_id => self.id)
    rooms += self.spaces.map(&:bigbluebutton_room)
    rooms += Space.public.map(&:bigbluebutton_room)
    rooms.uniq!
    rooms
  end

  # Returns the number of unread private messages for this user
  def unread_private_messages
    PrivateMessage.inbox(self).select{|msg| !msg.checked}
  end

end
