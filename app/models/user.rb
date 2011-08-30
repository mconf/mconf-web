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

require 'digest/sha1'
class User < ActiveRecord::Base
  apply_simple_captcha

  # LoginAndPassword Authentication:
  acts_as_agent :activation => true,
                :openid_server => true

  validates_presence_of  :email
  validates_exclusion_of :login, :in => %w( xmpp_server )
  validates_format_of :email, :with => /^[\w\d._%+-]+@[\w\d.-]+\.[\w]{2,}$/

  acts_as_stage
  acts_as_taggable :container => false
  acts_as_resource :param => :login
  validates :login, :uniqueness => true

  has_one :profile, :dependent => :destroy
  has_many :events, :as => :author
  has_many :participants
  has_many :posts, :as => :author
  has_many :memberships, :dependent => :destroy
  #has_many :groups, :through => :memberships

  # exclusive and unique BBB Room for each user
  after_create :create_bbb_room
  after_update :update_bbb_room
  has_one :bigbluebutton_room, :as => :owner, :dependent => :destroy
  accepts_nested_attributes_for :bigbluebutton_room

  attr_accessible :captcha, :captcha_key, :authenticate_with_captcha
  attr_accessible :email2, :email3 , :machine_ids
  attr_accessible :timezone
  attr_accessible :expanded_post, :notification
  attr_accessible :chat_activation
  attr_accessible :special_event_id
  attr_accessor :special_event_id

  # TODO is_indexed comes from Ultrasphinx
=begin
  is_indexed :fields => ['login','email'],
             :conditions => "disabled = 0",
             :include => [ {:class_name => 'Profile',:field => 'full_name',:as => 'full_name'},
             { :class_name => 'Profile',:field => 'organization',:as => 'profile_organization'},
            #{ :class_name => 'Profile',:field => 'lastname',:as => 'profile_lastname'}
            ],

             :concatenate => [ { :class_name => 'Tag',:field => 'name',:as => 'tags',
                                 :association_sql => "LEFT OUTER JOIN taggings ON (users.`id` = taggings.`taggable_id` AND taggings.`taggable_type` = 'User') LEFT OUTER JOIN tags ON (tags.`id` = taggings.`tag_id`)"
             }]
=end

  default_scope :conditions => {:disabled => false}

  #constant for the notification attribute
  NOTIFICATION_VIA_EMAIL = 1
  NOTIFICATION_VIA_PM = 2

  # Profile

  def profile!
    if profile.blank?
      self.create_profile
    else
      profile
    end
  end

  def create_bbb_room
    create_bigbluebutton_room :owner => self,
                              :server => BigbluebuttonServer.first,
                              :param => self.login,
                              :name => self._full_name
  end

  def update_bbb_room
    if self.login_changed?
      bigbluebutton_room[:param] = self.login
    end
  end

  delegate :full_name, :logo, :organization, :city, :country, :to => :profile!
  alias_attribute :name, :full_name
  alias_attribute :title, :full_name
  alias_attribute :permalink, :login

  # Full name must go to the profile, but it is provided by the user in signing up
  # so we have to temporally cache it until the user is created; :_full_name
  attr_accessor :_full_name
  attr_accessible :_full_name
  has_permalink :_full_name, :login

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

  # user.login and space.permalink should be unique
  validate :validate_unique_login_against_spaces

  # method adapted from PermalinkFu.create_unique_permalink
  def validate_unique_login_against_spaces

    # there's some space with a permalink == self.login
    if Space.where(:permalink => self.login).count > 0
      if self.new_record?
        update_unique_permalink
      else
        self.errors.add :login, I18n.t('activerecord.errors.messages.taken')
      end
    end
  end

  def update_unique_permalink
    counter = 1
    limit, base = create_common_permalink
    return if limit.nil? # nil if the permalink has not changed or :if/:unless fail

    # check for duplication either on spaces permalinks or users logins
    while Space.where(:permalink => self.login).count > 0 or
        User.where(:login => self.login).count > 0

      # try a new value
      suffix = "-#{counter += 1}"
      new_value = "#{base[0..limit-suffix.size-1]}#{suffix}"
      send("#{self.class.permalink_field}=", new_value)
    end
  end

  def self.find_with_disabled *args
    self.with_exclusive_scope { find(*args) }
  end

  def <=>(user)
    self.login <=> user.login
  end

  def spaces
    stages.select{ |s| s.is_a?(Space) && !s.disabled? }.sort_by{ |s| s.name }
  end

  def other_public_spaces
    Space.public.all(:order => :name) - spaces
  end

  #this method let's the user to login with his e-mail
  def self.authenticate_with_login_and_password(login, password)
    u = if login =~ /@/
          if login =~ /(.*)@#{ Site.current.presence_domain }$/
            find_by_login $1
          else
            find_by_email login
          end
        else
          find_by_login login
        end

    u && u.password_authenticated?(password) ? u : nil
  end

  def self.atom_parser(data)
    e = Atom::Entry.parse(data)
    user = {}
    user[:login] = e.title.to_s
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


  def disable
    self.update_attribute(:disabled,true)
    self.agent_performances.each(&:destroy)
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

end
