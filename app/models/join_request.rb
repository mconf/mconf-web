# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class JoinRequest < ActiveRecord::Base
  include PublicActivity::Common

  TYPES = {
    invite: "invite",      # someone inviting someone else to join something
    request: "request",    # someone requesting to join something
    no_accept: "no_accept" # someone adding someone to something without asking
  }

  TYPES.each_pair do |type, value|
    define_method("is_#{type}?") {
      self.request_type == JoinRequest::TYPES[type]
    }
  end

  # the user that is being invited
  belongs_to :candidate, :class_name => "User"
  # the person that is inviting
  belongs_to :introducer, :class_name => "User"

  # the container (event, space)
  belongs_to :group, :polymorphic => true

  belongs_to :role

  validates :email, :presence => true, :email => true

  # The request can either be an invitation or a request for membership
  validates :request_type, :presence => true, inclusion: { in: JoinRequest::TYPES.values }

  after_initialize :init

  attr_writer :processed
  before_save :set_processed_at
  before_save :add_candidate_to_group
  before_save :set_default_role

  validates :candidate_id, presence: true

  validates_uniqueness_of :candidate_id,
                          :scope => [ :group_id, :group_type, :processed_at ]

  validates_uniqueness_of :email,
                          :scope => [ :group_id, :group_type, :processed_at ]

  validates_length_of :comment, maximum: 255

  def self.default_role
    Role.where(stage_type: 'Space', name: 'User').first
  end

  def to_param
    self.secret_token
  end

  # Create a new activity after saving
  after_create :new_activity
  def new_activity key=nil
    key ||= self.request_type

    parameters = { candidate_id: candidate.id, username: candidate.name }
    unless introducer.nil?
      parameters[:introducer_id] = introducer.id
      parameters[:introducer] = introducer.name
    end
    create_activity key, owner: self.group, recipient: candidate, parameters: parameters
  end

  # Has this Admission been processed?
  def processed?
    processed_at.present?
  end

  # Has this Admission been recently processed? (typically in this request)
  def recently_processed?
    @processed.present?
  end

  def space?
    group_type == 'Space'
  end

  private

  def init
    # Use secret token as the model :id
    self[:secret_token] ||= SecureRandom.urlsafe_base64(16)
  end

  def set_processed_at
    @processed && self.processed_at = Time.now.utc
  end

  def add_candidate_to_group
    group.add_member!(candidate, role.name) if accepted?
  end

  def set_default_role
    if self.role_id.blank?
      update_attributes(role_id: JoinRequest::default_role.id)
    end
  end
end
