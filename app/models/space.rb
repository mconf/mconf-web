# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.
#
# -------
# Space is one of the most important models in the application.
# Spaces consist of a group of multiple users and provide them with a single
# conference room, a posts wall, document repository and space events.
#
# A space can be public or private. Public spaces are open to be read by anyone,
# even users not logged in. Private spaces can only be read by members and membership
# has to be requested or granted via invitation or request.
#
# == Attributes
# * +name+ : String with a human friendly name of the space
# * +permalink+ : The string used to identify the space in URLs
# * +description+ : Text with a human friendly description of the space
# * +public+ : A boolean value denoting whether the space is public
# * +disabled+: A boolean value denoting whether the space has been disabled
# * +logo_image+: A LogoUploader with the data for the image logo
# * +repository+: A boolean value denoting whether document repository is enabled for the space
#
# == Relations
# * +users+: List of users belonging to the space (linked via Permission)
# * +permissions+: Links a user to the space and assigns a roles (see USER_ROLES)
# * +posts+: Posts made on the space wall
# * +attachments+: Attachment(s) uploaded to the space repository
#
# == Activities
# * "space.create": When a space is created (parameters: +user_id+, +username+)
# * "space.update": When a user updates a space (parameters: +user_id+, +username+)
# * "space.leave": When user leaves a space (parameters: +user_id+, +username+)
#

class Space < ActiveRecord::Base
  include PublicActivity::Common

  # TODO: temporary, review
  USER_ROLES = ["Admin", "User"]

  has_many :posts, :dependent => :destroy
  has_many :news, :dependent => :destroy
  has_many :attachments, :dependent => :destroy
  has_one :bigbluebutton_room, :as => :owner, :dependent => :destroy

  has_many :permissions, -> { where(:subject_type => 'Space') },
           :foreign_key => "subject_id"

  has_and_belongs_to_many :users,  -> { Permission.where(:subject_type => 'Space') },
                          :join_table => :permissions, :foreign_key => "subject_id"

  has_and_belongs_to_many :admins, -> { Permission.where(:permissions => {:subject_type => 'Space', :role_id => Role.find_by_name('Admin')}) },
                          :join_table => :permissions, :class_name => "User", :foreign_key => "subject_id"

  has_many :join_requests, -> { where(:group_type => 'Space') },
           :foreign_key => "group_id"

  if Mconf::Modules.mod_loaded?('events')
    has_many :events, -> { where(:owner_type => 'Space')}, :class_name => MwebEvents::Event,
             :foreign_key => "owner_id", :dependent => :destroy
  end

  # for the associated BigbluebuttonRoom
  # attr_accessible :bigbluebutton_room_attributes
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
  validates :permalink,
    presence: true,
    format: /\A[A-Za-z0-9\-_]*\z/,
    length: { minimum: 3 },
    identifier_uniqueness: true,
    room_param_uniqueness: true

  # the friendly name / slug for the space
  extend FriendlyId
  friendly_id :permalink

  after_validation :check_errors_on_bigbluebutton_room

  # TODO: review all accessors, if we still need them
  attr_accessor :invitation_ids
  attr_accessor :invitation_mails
  attr_accessor :invite_msg
  attr_accessor :inviter_id
  attr_accessor :invitations_role_id

  # attrs and methods for space logos
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h, :crop_img_w, :crop_img_h
  mount_uploader :logo_image, LogoImageUploader
  after_create :crop_logo
  after_update :crop_logo

  # By default spaces marked as disabled will not show in queries
  default_scope -> { where(:disabled => false) }

  # This scope can be used as a shorthand for spaces marked as public
  scope :public_spaces, -> { where(:public => true) }

  # Finds all the valid user roles for a Space
  def self.roles
    Space::USER_ROLES.map { |r| Role.find_by_name(r) }
  end

  def last_activity
    RecentActivity.where(owner: self).last
  end

  # Order by when the last activity in the space happened.
  # OPTIMIZE: Couldn't find a way to make Space.order_by_activity.count work. This query
  #   doesn't work well when a COUNT() goes around it.
  scope :order_by_activity, -> {
    Space.default_join_for_activities(Space.arel_table[Arel.star],
                                      'MAX(`activities`.`created_at`) AS lastActivity')
      .group(Space.arel_table[:id])
      .order('lastActivity DESC')
  }

  # Order by relevance: spaces that are currently more relevant to show to the users.
  # Orders primarily by the last activity in the space, considering only the date and ignoring
  # the time. Then orders by the number of activities.
  # OPTIMIZE: Couldn't find a way to make Space.order_by_relevance.count work. This query
  #   doesn't work well when a COUNT() goes around it.
  scope :order_by_relevance, -> {
    Space.default_join_for_activities(Space.arel_table[Arel.star],
                                      'MAX(DATE(`activities`.`created_at`)) AS lastActivity',
                                      'COUNT(`activities`.`id`) AS activityCount')
      .group(Space.arel_table[:id])
      .order('lastActivity DESC').order('activityCount DESC')
  }

  # Returns a relation with a pre-configured join that can be used in queries to find recent
  # activities related to a space.
  def self.default_join_for_activities(*args)
    join_on = RecentActivity.arel_table[:owner_type].eq(Space.name)
      .and(RecentActivity.arel_table[:owner_id].eq(Space.arel_table[:id]))
      .or(RecentActivity.arel_table[:owner_type].eq(BigbluebuttonRoom.name)
            .and(RecentActivity.arel_table[:owner_id].eq(BigbluebuttonRoom.arel_table[:id]))).to_sql
    join_sql = "LEFT JOIN #{RecentActivity.table_name} ON (#{join_on})"

    if args.count > 0
      select(args).joins(:bigbluebutton_room).joins(join_sql)
    else
      joins(:bigbluebutton_room).joins(join_sql)
    end
  end

  # Returns the next 'count' events (starting in the current date) in this space.
  def upcoming_events(count = 5)
    self.events.upcoming.order("start_on ASC").first(5)
  end

  # Add a `user` to this space with the role `role_name` (e.g. 'User', 'Admin').
  # TODO: if a user has a pending request to join the space it will still be there after if this
  # method is used, should we check this here?
  #
  # * +user+: user to be added as member
  # * +role_name+: A string denoting the role the user should receive after being added
  def add_member!(user, role_name='User')
    p = Permission.new :user => user,
      :subject => self,
      :role => Role.find_by(name: role_name, stage_type: 'Space')

    p.save!
  end

  # Creates a new activity related to this space
  def new_activity(key, user, join_request = nil)
    if join_request
      create_activity key, owner: join_request, recipient: user, parameters: { :username => user.name }
    else
      params = { username: user.name }
      # Treat update_logo and update as the same key
      key = 'update' if key == 'update_logo'

      if key.to_s == 'update'
        # Don't create activity if the model was updated and nothing changed
        attr_changed = previous_changes.except('updated_at').keys
        return unless attr_changed.present?

        params.merge!(changed_attributes: attr_changed)
      end

      create_activity key, owner: self, recipient: user, parameters: params
    end
  end

  def self.with_disabled
    self.unscoped
  end

  # TODO: review all public methods below

  # Disable the space from the website.
  # This can be used by global admins as a mean to disable access and indexing of this space in all areas of
  # the site. This acts as if it has been deleted, but the data is still there in the database and the space can be
  # enabled back with the method 'enable'
  def disable
    self.disabled = true
    self.name = "#{name.split(" RESTORED").first} DISABLED #{Time.now.to_i}"
    save!
  end

  # Re-enables a previously disabled space
  def enable
    self.disabled = false
    self.name = "#{name.split(" DISABLED").first} RESTORED"
    save!
  end

  # Checks to see if the given user is the only admin in this space
  def is_last_admin?(user)
    adm = self.admins
    adm.length == 1 && adm.include?(user)
  end

  # Checks to see if 'user' has the role 'options[:name]' in this space
  def role_for?(user, options={})
    p = permissions.find_by(:user_id => user.id)
    p.present? && options[:name] == p.role.name
  end

  # Returns a query with pending join requests for this space (that is users that requested membership)
  def pending_join_requests
    join_requests.where(:processed_at => nil, :request_type => JoinRequest::TYPES[:request])
  end

  # Returns a query with pending invitations for this space (that is users that were invited by space admins)
  def pending_invitations
    join_requests.where(:processed_at => nil, :request_type => JoinRequest::TYPES[:invite])
  end

  # Returns the join_request model for the given user in this space
  def pending_join_request_or_invitation_for(user)
    join_requests.where(:candidate_id => user, :processed_at => nil).first
  end

  # Denotes whether the user has a pending join request in this space
  def pending_join_request_or_invitation_for?(user)
    !pending_join_request_or_invitation_for(user).nil?
  end

  def pending_join_request_for(user)
    pending_join_requests.where(:candidate_id => user.id).first
  end

  def pending_join_request_for?(user)
    !pending_join_request_for(user).nil?
  end

  def pending_invitation_for(user)
    pending_invitations.where(:candidate_id => user.id).first
  end

  def pending_invitation_for?(user)
    !pending_invitation_for(user).nil?
  end

  # Returns whether the space's logo is being cropped.
  def is_cropping?
    logo_image.present? && crop_x.present?
  end

  private

  # Creates the webconf room after the space is created
  def create_webconf_room
    params = {
      :owner => self,
      :server => BigbluebuttonServer.default,
      :param => self.permalink,
      :name => self.name,
      :private => false,
      :moderator_key => SecureRandom.hex(4),
      :attendee_key => SecureRandom.hex(4),
      :logout_url => "/feedback/webconf/"
    }
    create_bigbluebutton_room(params)
  end

  # Updates the webconf room after updating the space
  def update_webconf_room
    if self.bigbluebutton_room
      params = {
        :name => self.name
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

  # Calls uploader methods to create a new image crop
  def crop_logo
    logo_image.recreate_versions! if is_cropping?
  end

end
