# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class Space < ActiveRecord::Base
  include PublicActivity::Common

  # TODO: temporary, review
  USER_ROLES = ["Admin", "User"]

  has_many :posts, :dependent => :destroy
  has_many :news, :dependent => :destroy
  has_many :attachments, :dependent => :destroy
  has_many :tags, :dependent => :destroy, :as => :container
  has_one :bigbluebutton_room, :as => :owner, :dependent => :destroy

  has_many :permissions, :foreign_key => "subject_id",
           :conditions => { :permissions => {:subject_type => 'Space'} }

  has_and_belongs_to_many :users, :join_table => :permissions,
                          :foreign_key => "subject_id",
                          :conditions => { :permissions => {:subject_type => 'Space'} }

  has_and_belongs_to_many :admins, :join_table => :permissions,
                          :class_name => "User", :foreign_key => "subject_id",
                          :conditions => {
                            :permissions => {
                              :subject_type => 'Space',
                              :role_id => Role.find_by_name('Admin')
                            }
                          }

  has_many :join_requests, :foreign_key => "group_id",
           :conditions => { :join_requests => {:group_type => 'Space'} }

  if Mconf::Modules.mod_loaded?('events')
    has_many :events, :class_name => MwebEvents::Event, :foreign_key => "owner_id",
             :dependent => :destroy, :conditions => {:owner_type => 'Space'}
  end

  # for the associated BigbluebuttonRoom
  attr_accessible :bigbluebutton_room_attributes
  accepts_nested_attributes_for :bigbluebutton_room
  after_update :update_webconf_room
  after_create :create_webconf_room

  validates :description, :presence => true

  validates :name, :presence => true,
                   :uniqueness => { :case_sensitive => false },
                   :length => { :minimum => 3 }

  # BigbluebuttonRoom requires an identifier with 3 chars generated from
  # 'permalink', so we require it to have have length >= 3
  # TODO: improve the format matcher, check specs for some values that are allowed today
  #   but are not really recommended (e.g. '---')
  validates :permalink, :uniqueness => { :case_sensitive => false },
                        :format => /^[A-Za-z0-9\-_]*$/,
                        :presence => true,
                        :length => { :minimum => 3 }

  # The permalink has to be unique not only for spaces, but across other
  # models as well
  validate :permalink_uniqueness

  # the friendly name / slug for the space
  extend FriendlyId
  friendly_id :permalink
  acts_as_resource :param => :permalink

  after_validation :check_errors_on_bigbluebutton_room

  # TODO: review all accessors, if we still need them
  attr_accessor :invitation_ids
  attr_accessor :invitation_mails
  attr_accessor :invite_msg
  attr_accessor :inviter_id
  attr_accessor :invitations_role_id

  # attrs and methods for space logos
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
  mount_uploader :logo_image, LogoImageUploader
  after_create :crop_logo
  after_update :crop_logo

  default_scope :conditions => { :disabled => false }

  scope :public, lambda { where(:public => true) }

  # Finds all the valid user roles for a Space
  def self.roles
    Space::USER_ROLES.map { |r| Role.find_by_name(r) }
  end

  # Returns the next 'count' events (starting in the current date) in this space.
  def upcoming_events(count=5)
    self.events.upcoming.first(5)
  end

  # Return the number of unique pageviews for this space using the Statistic model.
  # Will throw an exception if the data in Statistic in incorrect.
  def unique_pageviews
    # Use only the canonical aggregated url of the space (all views have been previously added here in the rake task)
    corresponding_statistics = Statistic.where('url LIKE ?', '/spaces/' + self.permalink)
    if corresponding_statistics.size == 0
      return 0
    elsif corresponding_statistics.size == 1
      return corresponding_statistics.first.unique_pageviews
    elsif corresponding_statistics.size > 1
      raise "Incorrectly parsed statistics"
    end
  end

  # Add a `user` to this space with the role `role_name` (e.g. 'User', 'Admin').
  # TODO: if a user has a pending request to join the space it will still be there after if this
  #  method is used, should we check this here?
  def add_member!(user, role_name='User')
    p = Permission.new
    p.user = user
    p.subject = self
    p.role = Role.find_by_name_and_stage_type(role_name, 'Space')
    p.save!
  end

  def new_activity key, user
    create_activity key, :owner => self, :parameters => { :user_id => user.id, :username => user.name }
  end

  def self.with_disabled
    where(:disabled => [true, false])
  end

  # TODO: review all public methods below

  def self.find_with_disabled *args
    self.with_exclusive_scope { find(*args) }
  end

  def self.find_with_disabled_and_param *args
    self.with_exclusive_scope { find_with_param(*args) }
  end

  def disable
    self.disabled = true
    self.name = "#{name.split(" RESTORED").first} DISABLED #{Time.now.to_i}"
    save!
  end

  def enable
    self.disabled = false
    self.name = "#{name.split(" DISABLED").first} RESTORED"
    save!
  end

  # Basically checks to see if the given user is the only admin in this space
  def is_last_admin?(user)
    adm = self.admins
    adm.length == 1 && adm.include?(user)
  end

  # Checks to see if 'user' has the role 'options[:name]' in this space
  def role_for?(user, options={})
    p = permissions.find_by_user_id(user)
    users.include?(user) && options[:name] == Role.find(p.role_id).name
  end

  def pending_join_requests
    join_requests.where(:processed_at => nil, :request_type => 'request')
  end

  def pending_invitations
    join_requests.where(:processed_at => nil, :request_type => 'invite')
  end

  def pending_join_request_for?(user)
    pending_join_requests.where(:candidate_id => user).size > 0
  end

  private

  def permalink_uniqueness
    unless User.find_by_username(self.permalink).blank?
      errors.add(:permalink, "has already been taken")
    end
  end

  # Creates the webconf room after the space is created
  def create_webconf_room
    params = {
      :owner => self,
      :server => BigbluebuttonServer.default,
      :param => self.permalink,
      :name => self.permalink,
      :private => !self.public,
      :moderator_password => SecureRandom.hex(4),
      :attendee_password => SecureRandom.hex(4),
      :logout_url => "/feedback/webconf/"
    }
    create_bigbluebutton_room(params)
  end

  # Updates the webconf room after updating the space
  def update_webconf_room
    if self.bigbluebutton_room
      params = {
        :param => self.permalink,
        :name => self.permalink,
        :private => !self.public
      }
      bigbluebutton_room.update_attributes(params)
    end
  end

  # Checks if an error happened when creating the associated 'bigbluebutton_room'
  # and sets this error in an attribute that can be seen by the user in the views.
  # TODO: Check for any error, not only on :param; test it better; do it for users too.
  def check_errors_on_bigbluebutton_room
    if self.bigbluebutton_room and self.bigbluebutton_room.errors[:param].size > 0
      self.errors.add :permalink, I18n.t('activerecord.errors.messages.invalid_identifier', :id => self.bigbluebutton_room.param)
    end
  end

  def crop_logo
    logo_image.recreate_versions! if crop_x.present?
  end

end
