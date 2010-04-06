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

class Admission < ActiveRecord::Base
  attr_writer :processed
  before_save :processed

  belongs_to :candidate, :polymorphic => true
  belongs_to :group, :polymorphic => true
  belongs_to :introducer, :polymorphic => true
  belongs_to :role

  attr_protected :candidate_id, :candidate_type, :candidate 
  attr_protected :group_id, :group_type, :group


  before_validation :sync_candidate_email

  validates_uniqueness_of :candidate_id,
                          :scope => [ :candidate_type, :group_id, :group_type ],
                          :allow_nil => true, :if => Proc.new { |admission| admission.type == Invitation || admission.type==JoinRequest }
  validates_uniqueness_of :candidate_type,
                          :scope => [ :candidate_id,   :group_id, :group_type ],
                          :allow_nil => true, :if => Proc.new { |admission| admission.type == Invitation || admission.type==JoinRequest }
  validates_uniqueness_of :email,
                          :scope => [ :group_id, :group_type ], :if => Proc.new { |admission| admission.type == Invitation || admission.type==JoinRequest }

  validate_on_create :candidate_without_role, :if => Proc.new { |admission| admission.type == Invitation || admission.type==JoinRequest }

  after_save :to_performance!
  
  acts_as_sortable :columns => [ :candidate,
                                 :email,
                                 :group,
                                 :role ]
  named_scope :pending, lambda { 
    { :conditions => { :processed_at => nil } }
  }

  # Has this Admission been processed?
  def processed?
    processed_at.present?
  end

  # Has this Admission been recently processed? (typically in this request)
  def recently_processed?
    @processed.present?
  end

  # State of this Admission. Values are :not_processed, :accepted or :discarded
  def state
    processed? ? 
      accepted? ? 
       :accepted :
       :discarded :
      :not_processed
  end

  # A message according to Admission state, using I18n
  def state_message
    I18n.t "#{ self.class.to_s.underscore }.#{ state }"
  end

  def candidate_name
    candidate.try(:name) || email.split('@').first
  end

  private

  def processed
    @processed && self.processed_at = Time.now.utc
  end

  def sync_candidate_email
    if email.blank? && candidate && candidate.respond_to?(:email)
      self.email = candidate.email
    end

    if candidate.blank?
      self.candidate = ActiveRecord::Agent::Invite.find_all(email).first
    end
  end

  def candidate_without_role
    return if group.blank? || candidate.blank?

    if group.role_for? candidate
      errors.add :candidate, I18n.t('admission.errors.candidate_has_role')
    end
  end

  def to_performance!
    return unless recently_processed? && accepted? && group && role

    unless group.role_for? candidate
      if group.class != Event
        Performance.create! :agent => candidate,
                            :stage => group,
                            :role  => role
      else
        Performance.create! :agent => candidate,
                            :stage => group,
                            :role  => role
        unless group.space.role_for? candidate
          Performance.create! :agent => candidate,
                              :stage => group.space,
                              :role  => role
        end
      end
    end
  end
end
