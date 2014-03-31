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
                  :login, :username, :approved
  # TODO: block :username from being modified after registration
  # attr_accessible :username, :as => :create

  # TODO: improve the format matcher, check specs for some values that are allowed today
  #   but are not really recommended (e.g. '-')
  validates :username, :uniqueness => { :case_sensitive => false },
                       :presence => true,
                       :format => /^[A-Za-z0-9\-_]*$/,
                       :length => { :minimum => 1 }

  # The username has to be unique not only for user, but across other
  # models as well
  validate :username_uniqueness

  extend FriendlyId
  friendly_id :username

  def ability
    @ability ||= Abilities.ability_for(self)
  end

  # Returns true if the user is anonymous (not registered)
  def anonymous?
    self.new_record?
  end

  # Returns a query with all the activity related to this user: activities in his spaces and
  # web conference rooms
  def all_activity
    user_room = self.bigbluebutton_room
    spaces = self.spaces
    space_rooms = spaces.map{ |s| s.bigbluebutton_room.id }

    t = RecentActivity.arel_table
    in_spaces = t[:owner_id].in(spaces.map(&:id)).and(t[:owner_type].eq('Space'))
    in_room = t[:owner_id].in(user_room.id).and(t[:owner_type].eq('BigbluebuttonRoom'))
    in_space_rooms = t[:owner_id].in(space_rooms).and(t[:owner_type].eq('BigbluebuttonRoom'))
    RecentActivity.where(in_spaces.or(in_room).or(in_space_rooms))
  end

  apply_simple_captcha

  validates :email, :presence => true, :email => true

  acts_as_resource :param => :username

  has_and_belongs_to_many :spaces, :join_table => :permissions,
                          :association_foreign_key => "subject_id",
                          :conditions => { :permissions => {:subject_type => 'Space'} }

  has_many :permissions, :dependent => :destroy
  has_one :profile, :dependent => :destroy
  has_many :posts, :as => :author, :dependent => :destroy
  has_one :bigbluebutton_room, :as => :owner, :dependent => :destroy
  has_one :ldap_token, :dependent => :destroy

  accepts_nested_attributes_for :bigbluebutton_room

  # TODO: see JoinRequestsController#create L50
  attr_accessible :created_at, :updated_at, :activated_at, :disabled
  attr_accessible :captcha, :captcha_key, :authenticate_with_captcha
  attr_accessible :email2, :email3
  attr_accessible :timezone
  attr_accessible :expanded_post
  attr_accessible :notification
  attr_accessible :superuser
  attr_accessible :can_record
  attr_accessible :receive_digest

  # Full name must go to the profile, but it is provided by the user when
  # signing up so we have to cache it until the profile is created
  attr_accessor :_full_name
  attr_accessible :_full_name

  # BigbluebuttonRoom requires an identifier with 3 chars generated from :name
  # So we'll require :_full_name and :username to have length >= 3
  # TODO: review, see issue #737
  validates :_full_name, :presence => true, :length => { :minimum => 3 }, :on => :create

  # for the associated BigbluebuttonRoom
  attr_accessible :bigbluebutton_room_attributes
  accepts_nested_attributes_for :bigbluebutton_room

  after_create :create_webconf_room
  after_update :update_webconf_room

  before_create :automatically_approve_if_needed

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
      :server => BigbluebuttonServer.default,
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

    # Checking if we have to join a space and/or event
    invites = JoinRequest.where :email => user.email
    invites.each do |invite|
      if invite.space?
        space.add_member!(user)
      end
    end

  end

  # Builds a guest user based on the e-mail
  def self.build_guest opt={}
    return nil if opt[:email].blank?

    User.new :email => opt[:email], :username => I18n.t('_other.user.guest', :email => opt[:email])
  end

  def self.find_with_disabled *args
    self.with_exclusive_scope { find_by_username(*args) }
  end

  def self.find_by_id_with_disabled *args
    self.with_exclusive_scope { find(*args) }
  end

  def self.with_disabled
    where(:disabled => [true, false])
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
    # Spaces the user admins
    admin_in = self.permissions.where(:subject_type => 'Space', :role_id => Role.find_by_name('Admin')).map(&:subject)
    # Disabled spaces will be nil at this point, remove them
    admin_in.compact!

    self.update_attribute(:disabled,true)
    self.permissions.each(&:destroy)

    # Disable spaces if this was the last admin
    admin_in.each do |space|
      space.disable if space.admins.empty?
    end
  end

  def enable
    self.update_attribute(:disabled,false)
  end

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

  def events
    ids = MwebEvents::Event.where(:owner_type => 'User', :owner_id => id).map(&:id)
    ids += self.permissions.where(:subject_type => 'MwebEvents::Event', :user_id => id).map(&:subject_id)
    MwebEvents::Event.where(:id => ids)
  end

  def has_events_in_this_space?(space)
    !events.select{|ev| ev.owner_type=='Space' && ev.owner_id==space}.empty?
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

  # Automatically approves the user if the current site is not requiring approval
  # on registration.
  def automatically_approve_if_needed
    self.approved = true unless Site.current.require_registration_approval?
  end

  # Sets the user as approved
  def approve!
    self.update_attributes(:approved => true)
  end

  # Sets the user as not approved
  def disapprove!
    self.update_attributes(:approved => false)
  end

  # Whether the user should be notified via email
  def notify_via_email?
    self.notification == User::NOTIFICATION_VIA_EMAIL
  end

  # Whether the user should be notified via private message
  def notify_via_private_message?
    self.notification == User::NOTIFICATION_VIA_PM
  end

  # Overrides a method from devise, see:
  # https://github.com/plataformatec/devise/wiki/How-To%3a-Require-admin-to-activate-account-before-sign_in
  def active_for_authentication?
    super && (!Site.current.require_registration_approval? || approved?)
  end

  # Overrides a method from devise, see:
  # https://github.com/plataformatec/devise/wiki/How-To%3a-Require-admin-to-activate-account-before-sign_in
  def inactive_message
    if !approved? && Site.current.require_registration_approval?
      :not_approved
    else
      super # Use whatever other message
    end
  end

  # Method used by MwebEvents
  def admin?
    superuser
  end

  private

  def username_uniqueness
    unless Space.find_by_permalink(self.username).blank?
      errors.add(:username, "has already been taken")
    end
  end

end
