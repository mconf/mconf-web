# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'devise/encryptors/station_encryptor'
require 'digest/sha1'
require './lib/mconf/approval_module'

class User < ActiveRecord::Base
  include PublicActivity::Common
  include Mconf::ApprovalModule
  include Mconf::DisableModule

  # TODO: block :username from being modified after registration

  ## Devise setup
  # Other available devise modules are:
  # :token_authenticatable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :async, :registerable,
         :confirmable, :recoverable, :rememberable, :trackable,
         :validatable, :encryptable
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

  validates :username,
    presence: true,
    format: /\A[A-Za-z0-9\-_]*\z/,
    length: { minimum: 1 },
    identifier_uniqueness: true,
    room_param_uniqueness: true

  extend FriendlyId
  friendly_id :username

  validates :email, uniqueness: true, presence: true, email: true

  has_and_belongs_to_many :spaces, -> { where(permissions: {subject_type: 'Space'}).uniq },
                          join_table: :permissions, association_foreign_key: "subject_id"

  has_many :join_requests, :foreign_key => :candidate_id, :dependent => :destroy
  has_many :permissions, :dependent => :destroy
  has_one :profile, :dependent => :destroy
  has_many :posts, :as => :author
  has_one :bigbluebutton_room, :as => :owner, :dependent => :destroy
  has_one :ldap_token, :dependent => :destroy
  has_one :shib_token, :dependent => :destroy

  after_initialize :init

  accepts_nested_attributes_for :bigbluebutton_room

  # Will be set to a user when the user was registered by an admin.
  attr_accessor :created_by

  # Full name must go to the profile, but it is provided by the user when
  # signing up so we have to cache it until the profile is created
  attr_accessor :_full_name

  # BigbluebuttonRoom requires an identifier with 3 chars generated from :name
  # So we'll require :_full_name and :username to have length >= 3
  validates :_full_name, :presence => true, :length => { :minimum => 3 }, :on => :create

  # for the associated BigbluebuttonRoom
  # attr_accessible :bigbluebutton_room_attributes
  accepts_nested_attributes_for :bigbluebutton_room

  after_create :create_webconf_room
  after_update :update_webconf_room

  before_destroy :before_disable_and_destroy, prepend: true

  default_scope { where(disabled: false) }

  # constants for the receive_digest attribute
  RECEIVE_DIGEST_NEVER = 0
  RECEIVE_DIGEST_DAILY = 1
  RECEIVE_DIGEST_WEEKLY = 2

  scope :search_by_terms, -> (words, include_private=false) {
    query = joins(:profile).includes(:profile).order("profiles.full_name")

    words ||= []
    words = [words] unless words.is_a?(Array)
    query_strs = []
    query_params = []

    words.each do |word|
      str  = "profiles.full_name LIKE ? OR users.username LIKE ?"
      str += " OR users.email LIKE ?" if include_private
      query_strs << str
      query_params += ["%#{word}%", "%#{word}%"]
      query_params += ["%#{word}%"] if include_private
    end

    query.where(query_strs.join(' OR '), *query_params.flatten)
  }

  alias_attribute :name, :full_name
  alias_attribute :title, :full_name
  alias_attribute :permalink, :username

  delegate :full_name, :logo, :organization, :city, :country, :logo_image, :logo_image_url, :to => :profile

  # In case the profile is accessed before it is created, we build one on the fly.
  # Important specially because we have method delegated to the profile.
  def profile_with_initialize
    profile_without_initialize || build_profile
  end
  alias_method_chain :profile, :initialize

  def ability
    @ability ||= Abilities.ability_for(self)
  end

  # Returns true if the user is anonymous (not registered)
  def anonymous?
    self.new_record?
  end

  def require_approval?
    Site.current.require_registration_approval
  end

  def create_webconf_room
    params = {
      :owner => self,
      :server => BigbluebuttonServer.default,
      :param => self.username,
      :name => self._full_name,
      :logout_url => "/feedback/webconf/",
      :moderator_key => SecureRandom.hex(4),
      :attendee_key => SecureRandom.hex(4)
    }
    create_bigbluebutton_room(params)
  end

  def update_webconf_room
    if self.username_changed?
      params = { param: self.username }
      bigbluebutton_room.update_attributes(params)
    end
  end

  # Full location: city + country
  def location
    [ self.city.presence, self.country.presence ].compact.join(', ')
  end

  after_create :create_user_profile
  def create_user_profile
    create_profile({full_name: self._full_name})
  end

  # Builds a guest user based on the e-mail
  def self.build_guest opt={}
    return nil if opt[:email].blank?

    User.new :email => opt[:email], :username => I18n.t('_other.user.guest', :email => opt[:email])
  end

  def self.with_disabled
    unscope(where: :disabled) # removes the target scope only
  end

  def <=>(user)
    self.username <=> user.username
  end

  def other_public_spaces
    Space.public_spaces.order('name') - spaces
  end

  def fellows(name=nil, limit=nil)
    limit = limit || 5            # default to 5
    limit = 50 if limit.to_i > 50 # no more than 50

    # ids of unique users that belong to the same spaces
    ids = Permission.where(:subject_id => self.space_ids).pluck(:user_id)

    # filters and selects the users
    query = User.where(:id => ids).joins(:profile).where("users.id != ?", self.id)
    query = query.where("profiles.full_name LIKE ?", "%#{name}%") unless name.nil?
    query.limit(limit).order("profiles.full_name").includes(:profile)
  end

  def public_fellows
    fellows
  end

  def private_fellows
    ids = spaces.where(:public => false).map(&:user_ids).flatten.compact
    User.where(:id => ids).where("users.id != ?", self.id).sort_by{ |u| u.name.downcase }
  end

  def events
    ids = Event.where(:owner_type => 'User', :owner_id => id).ids
    ids += permissions.where(:subject_type => 'Event').pluck(:subject_id)
    Event.where(:id => ids)
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
    rooms += Space.public_spaces.map(&:bigbluebutton_room)
    rooms.uniq!
    rooms
  end

  # Sets the user as approved and skips confirmation
  def approve!
    skip_confirmation! unless confirmed?
    update_attributes(approved: true)
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

  # Return the list of spaces in which the user has a pending join request or invitation.
  def pending_spaces
    requests = JoinRequest.where(:candidate_id => self, :processed_at => nil, :group_type => 'Space')
    ids = requests.pluck(:group_id)
    # note: not 'find' because some of the spaces might be disabled and 'find' would raise
    #   an exception
    Space.where(:id => ids)
  end

  after_create :new_activity_user_created
  def new_activity_user_created
    if created_by.present?
      create_activity 'created_by_admin', owner: created_by, notified: false, recipient: self
    else
      create_activity 'created', owner: self, notified: !require_approval?, recipient: self
    end
  end

  def created_by_shib?
    ShibToken.user_created_by_shib?(self)
  end

  def created_by_ldap?
    LdapToken.user_created_by_ldap?(self)
  end

  def no_local_auth?
    created_by_shib? || created_by_ldap?
  end

  protected

  def before_disable_and_destroy
    # All the spaces the user is an admin of
    admin_in = self.permissions
      .where(subject_type: 'Space', role_id: Role.find_by_name('Admin'))
      .map(&:subject)
    admin_in.compact! # remove nil (disabled) spaces

    # Some associations are removed even if the user is only
    # being disabled and not completely removed.
    permissions.each(&:destroy)
    join_requests.each(&:destroy)

    # Disable spaces if this user was the last admin
    admin_in.each do |space|
      space.disable if space.admins.empty?
    end
  end

  # For the disable module
  def before_disable
    before_disable_and_destroy
  end

  def init
    @created_by = nil
  end
end
