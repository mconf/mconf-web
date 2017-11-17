# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

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
# * +slug+ : The string used to identify the space in URLs
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

require './lib/mconf/approval_module'

class Space < ActiveRecord::Base
  include PublicActivity::Common
  include Mconf::ApprovalModule
  include Mconf::DisableModule

  USER_ROLES = ["Admin", "User"]

  has_many :posts, :dependent => :destroy
  has_many :attachments, :dependent => :destroy
  has_one :bigbluebutton_room, :as => :owner, :dependent => :destroy

  has_many :permissions, -> { where(:subject_type => 'Space') },
           :foreign_key => "subject_id"

  has_and_belongs_to_many :users,  -> { Permission.where(:subject_type => 'Space') },
                          :join_table => :permissions, :foreign_key => "subject_id"

  has_and_belongs_to_many :admins, -> { Permission.where(:permissions => {:subject_type => 'Space', :role_id => Role.find_by_name('Admin')}) },
                          :join_table => :permissions, :class_name => "User", :foreign_key => "subject_id"

  has_many :join_requests, -> { where(:group_type => 'Space') },
           foreign_key: "group_id"

  has_many :events, -> { where(:owner_type => 'Space')}, class_name: Event,
           foreign_key: "owner_id", dependent: :destroy

  # for the associated BigbluebuttonRoom
  # attr_accessible :bigbluebutton_room_attributes
  accepts_nested_attributes_for :bigbluebutton_room
  after_update :update_webconf_room
  after_create :create_webconf_room

  acts_as_taggable

  validates :description, :presence => true

  validates :name, :presence => true,
                   :uniqueness => { :case_sensitive => false },
                   :length => { :minimum => 3 }

  # BigbluebuttonRoom requires an identifier with 3 chars generated from
  # 'slug', so we require it to have have length >= 3
  # TODO: improve the format matcher, check specs for some values that are allowed today
  #   but are not really recommended (e.g. '---')
  validates :slug,
    presence: true,
    format: /\A[A-Za-z0-9\-_]*\z/,
    length: { minimum: 3 },
    identifier_uniqueness: true,
    blacklist: true,
    room_slug_uniqueness: true

  # the friendly name / slug for the space
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged, slug_column: :slug
  def slug_candidates
    [ Mconf::Identifier.unique_mconf_id(name) ]
  end

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

  # By default spaces marked as disabled will not show in queries.
  # Also ensure spaces will never be found if disabled.
  default_scope -> {
    if Mconf::Modules.mod_enabled?('spaces')
      where(disabled: false)
    else
      Space.none
    end
  }

  # This scope can be used as a shorthand for spaces marked as public
  scope :public_spaces, -> { where(:public => true) }

  # Search spaces based on a list of words
  # TODO: can_manage is never used, should hide private spaces
  scope :search_by_terms, -> (words, can_manage=false) {
    if words.present?
      words ||= []
      words = [words] unless words.is_a?(Array)
      query_strs = []
      query_params = []
      query_orders = []

      words.reject(&:blank?).each do |word|
        str  = "name LIKE ? OR description LIKE ?"
        query_strs << str
        query_params += ["%#{word}%", "%#{word}%"]
        query_orders += [
          "CASE WHEN name LIKE '%#{word}%' THEN 1 ELSE 0 END + \
           CASE WHEN description LIKE '%#{word}%' THEN 1 ELSE 0 END"
        ]
      end
      query = Space.where(query_strs.join(' OR '), *query_params.flatten)
                .order(query_orders.join(' + ') + " DESC")
    end

    query
  }

  # The default ordering for search methods
  scope :search_order, -> {
    order("name")
  }

  # Finds all the valid user roles for a Space
  def self.roles
    Space::USER_ROLES.map { |r| Role.find_by_name(r) }
  end

  # Order by when the last activity in the space happened.
  scope :order_by_activity, -> {
    Space.order('last_activity DESC').order('name ASC')
  }

  # Order by relevance: spaces that are currently more relevant to show to the users.
  # Orders primarily by the last activity in the space, considering only the date and ignoring
  # the time. Then orders by the number of activities.
  scope :order_by_relevance, -> {
    Space.order('last_activity DESC').order('last_activity_count DESC').order('name ASC')
  }

  # Returns a relation with a pre-configured join that can be used in queries to find recent
  # activities related to a space.
  def self.default_join_for_activities(*args)
    # manually join `:bigbluebutton_room` because we want a "LEFT JOIN" and rails uses
    # "INNER LEFT JOIN" by default when using `joins()`.
    join_room_on = BigbluebuttonRoom.arel_table[:owner_type].eq(Space.name)
              .and(BigbluebuttonRoom.arel_table[:owner_id].eq(Space.arel_table[:id])).to_sql
    join_room_sql = "LEFT JOIN #{BigbluebuttonRoom.table_name} ON (#{join_room_on})"

    # manually join activities because we also want a "LEFT JOIN"
    join_on = RecentActivity.arel_table[:owner_type].eq(Space.name)
              .and(RecentActivity.arel_table[:owner_id].eq(Space.arel_table[:id]))
              .or(RecentActivity.arel_table[:owner_type].eq(BigbluebuttonRoom.name)
                   .and(RecentActivity.arel_table[:owner_id].eq(BigbluebuttonRoom.arel_table[:id]))).to_sql
    join_sql = "LEFT JOIN #{RecentActivity.table_name} ON (#{join_on})"

    if args.count > 0
      select(args).joins(join_room_sql).joins(join_sql)
    else
      joins(join_room_sql).joins(join_sql)
    end
  end

  def self.calculate_last_activity_indexes!
    # Big join of all the tables, count activities and find the last activity in each space
    # Note: DATE() implies that the maximum precision will be a day
    spaces_with_activities =
      Space.default_join_for_activities(Space.arel_table[Arel.star],
        'MAX(DATE(`activities`.`created_at`)) AS lastActivity',
        'COUNT(`activities`.`id`) AS activityCount').group(Space.arel_table[:id])

    # Use these calculations to set the indexes in the space table
    spaces_with_activities.find_each do |space|
      space.update_attributes last_activity: space.lastActivity, last_activity_count: space.activityCount
    end
  end

  def require_approval?
    Site.current.require_space_approval?
  end

  # Returns the next 'count' events (starting in the current date) in this space.
  def upcoming_events(count = 5)
    self.events.upcoming.order("start_on ASC").first(5)
  end

  # Returns the latest 'count' posts created in this space
  def latest_posts(count = 3)
    posts.where(:parent_id => nil).where('author_id is not null').order("updated_at DESC").first(count)
  end

  # Returns the latest 'count' users that have joined this space
  def latest_users(count = 3)
    users.order("permissions.created_at DESC").first(count)
  end

  # Returns a list of permissions ordered by the user's name
  def permissions_ordered_by_name
    permissions
      .joins("LEFT JOIN profiles on permissions.user_id = profiles.user_id")
      .order("profiles.full_name ASC")
  end

  # Add a `user` to this space with the role `role_name` (e.g. 'User', 'Admin').
  # TODO: if a user has a pending request to join the space it will still be there after if this
  # method is used, should we check this here?
  #
  # * +user+: user to be added as member
  # * +role_name+: A string denoting the role the user should receive after being added
  def add_member!(user, role_name='User')
    p = Permission.new(user: user,
      subject: self,
      role: Role.find_by(name: role_name, stage_type: 'Space')
    )
    p.save!
  end

  # Removes a `user` from this space.
  # If the user is a member, returns whether the user was removed or not.
  # Otherwise returns always true.
  #
  # * +user+: user to be removed
  def remove_member!(user)
    p = Permission.where(user: user, subject: self)
    p.empty? ? true : p.destroy_all.any?
  end

  # Creates a new activity related to this space
  def new_activity(key, user)
    params = { username: user.name, trackable_name: name }

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

  def self.with_disabled
    unscope(where: :disabled) # removes the target scope only
    # TODO: test what happens when the spaces mod is disabled
  end

  # TODO: review all public methods below
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

  def small_logo_image?
    logo_image.height < 100 || logo_image.width < 100
  end

  def initials
    self.name.split(' ').collect{ |w| w[0] }.join('')
  end

  private

  # Creates the webconf room after the space is created
  def create_webconf_room
    params = {
      owner: self,
      slug: self.slug,
      name: self.name,
      private: false,
      moderator_key: SecureRandom.hex(8),
      attendee_key: SecureRandom.hex(4),
      logout_url: "/feedback/webconf/"
    }
    create_bigbluebutton_room(params)
  end

  # Updates the webconf room after updating the space
  def update_webconf_room
    if self.bigbluebutton_room
      params = { slug: self.slug }

      # update the name only if it was unchanged
      params[:name] = self.name if self.name_was == self.bigbluebutton_room.name

      bigbluebutton_room.update_attributes(params)
    end
  end

  # Checks if an error happened when creating the associated 'bigbluebutton_room'
  # and sets this error in an attribute that can be seen by the user in the views.
  # TODO: Check for any error, not only on :slug; test it better; do it for users too.
  def check_errors_on_bigbluebutton_room
    if self.bigbluebutton_room and self.bigbluebutton_room.errors[:slug].size > 0
      self.errors.add :slug, I18n.t('activerecord.errors.messages.invalid_identifier', id: self.bigbluebutton_room.slug)
    end
  end

  # Calls uploader methods to create a new image crop
  def crop_logo
    logo_image.recreate_versions! if is_cropping?
  end
end
