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
                       :length => { :minimum => 3 }
  extend FriendlyId
  friendly_id :username

###

  acts_as_agent

  apply_simple_captcha

  validates_presence_of  :email
  validates_format_of :email, :with => /^[\w\d._%+-]+@[\w\d.-]+\.[\w]{2,}$/

  acts_as_stage
  acts_as_taggable :container => false
  acts_as_resource :param => :username

  has_one :profile, :dependent => :destroy
  has_many :events, :as => :author
  has_many :participants
  has_many :posts, :as => :author
  has_many :memberships, :dependent => :destroy
  has_one :bigbluebutton_room, :as => :owner, :dependent => :destroy

  accepts_nested_attributes_for :bigbluebutton_room

  # TODO: see JoinRequestsController#create L50
  attr_accessible :created_at, :updated_at, :activated_at, :disabled
  attr_accessible :captcha, :captcha_key, :authenticate_with_captcha
  attr_accessible :email2, :email3, :machine_ids
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
    create_bigbluebutton_room :owner => self,
                              :server => BigbluebuttonServer.first,
                              :param => self.username,
                              :name => self._full_name,
                              :logout_url => "/feedback/webconf/"
  end

  def update_webconf_room
    if self.username_changed?
      bigbluebutton_room[:param] = self.username
    end
  end

  delegate :full_name, :logo, :organization, :city, :country, :to => :profile!
  alias_attribute :name, :full_name
  alias_attribute :title, :full_name
  alias_attribute :permalink, :username

  # Full location: city + country
  def location
    [ self.city, self.country ].join(', ')
  end


  after_create do |user|
    user.create_profile :full_name => user._full_name

    # Checking if we have to join the space and the event
    if (! user.special_event.nil?)
      Performance.create! :agent => user,
                          :stage => user.special_event.space,
                          :role  => Role.find_by_name("Invited")

      Performance.create! :agent => user,
                          :stage => user.special_event,
                          :role  => Role.find_by_name("Invitedevent")

      part_aux = Participant.new
      part_aux.email = user.email
      part_aux.user_id = user.id
      part_aux.event_id = user.special_event.id
      part_aux.attend = true
      part_aux.save!
    end

  end

  def self.find_with_disabled *args
    self.with_exclusive_scope { find(*args) }
  end

  def <=>(user)
    self.username <=> user.username
  end

  def spaces
    stages.select{ |s| s.is_a?(Space) && !s.disabled? }.sort_by{ |s| s.name }
  end

  def other_public_spaces
    Space.public.all(:order => :name) - spaces
  end

  #this method let's the user to login with his e-mail
  def self.authenticate_with_login_and_password(login, password)
    # u = if login =~ /@/
    #       if login =~ /(.*)@#{ Site.current.presence_domain }$/
    #         find_by_login $1
    #       else
    #         find_by_email login
    #       end
    #     else
    #       find_by_login login
    #     end

    # u && u.password_authenticated?(password) ? u : nil
  end

  def user_count
    users.size
  end

  def self.atom_parser(data)
    e = Atom::Entry.parse(data)
    user = {}
    user[:username] = e.title.to_s
    user[:password] = e.get_elem(e.to_xml, "http://sir.dit.upm.es/schema", "password").text
    user[:password_confirmation] = user[:password]
    e.get_elems(e.to_xml, "http://schemas.google.com/g/2005", "email").each do |email|
        user[:email] = email.attributes['address']
    end
    t = []
    e.categories.each do |c|
      unless c.scheme
        t << c.term
      end
    end
    tags = t.join(sep=",")

    { :user => user, :tags => tags}
  end

  def self.select_all_users(name)
    tags = []
    members = Profile.where("full_name like ?", "%#{ name }%").select(['full_name', 'id']).limit(4)
    members.each do |f|
      user = User.find(f.id)
      tags.push("id"=>user.username, "name"=>f.full_name)
    end
    tags
  end

  def disable
    self.update_attribute(:disabled,true)
    self.agent_permissions.each(&:destroy)
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

  def public_fellows
    fellows
  end

  def private_fellows
    stages(:type => "Space").select{|x| x.public == false}.map(&:actors).flatten.compact.uniq.sort{ |x, y| x.name <=> y.name }
  end

  authorizing do |agent, permission|
    false if disabled?
  end

  authorizing do |agent, permission|
    true if permission == :read
  end

  authorizing do |agent, permission|
    true if agent == self
  end

  def has_events_in_this_space?(space)
    !events.select{|ev| ev.space==space}.empty?
  end

  def special_event

    if (self.special_event_id.blank?)
      nil
    else
      event_aux = Event.find(self.special_event_id)
      # Only allow special_event_id for the quick registering way when the space of the event is public
      if (event_aux.space.public)
        event_aux
      else
        nil
      end
    end
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
