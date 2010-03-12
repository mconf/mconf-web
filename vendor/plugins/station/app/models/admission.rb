class Admission < ActiveRecord::Base
  attr_writer :processed
  before_save :processed

  belongs_to :candidate, :polymorphic => true
  belongs_to :group, :polymorphic => true
  belongs_to :introducer, :polymorphic => true
  belongs_to :role

  attr_protected :candidate_id, :candidate_type, :candidate 
  attr_protected :group_id, :group_type, :group


  before_validation :extract_email, :sync_candidate_email

  validates_uniqueness_of :candidate_id,
                          :scope => [ :candidate_type, :group_id, :group_type ],
                          :allow_nil => true
  validates_uniqueness_of :candidate_type,
                          :scope => [ :candidate_id,   :group_id, :group_type ],
                          :allow_nil => true
  validates_uniqueness_of :email,
                          :scope => [ :group_id, :group_type ]
  validates_format_of :email, :with => /^[\w\d._%+-]+@[\w\d.-]+\.[\w]{2,}$/

  validate_on_create :candidate_without_role
  validate :candidate_is_not_introducer

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

  # Get the email address from "User <user@example.org>" to "user@example.org"
  def extract_email
    if email =~ /<(.*)>/
      self.email = $1
    end
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

  def candidate_is_not_introducer
    if candidate == introducer
      errors.add_to_base I18n.t('admission.errors.candidate_equals_introducer')
    end
  end

  def to_performance!
    return unless recently_processed? && accepted? && group && role

    Performance.create! :agent => candidate,
                        :stage => group,
                        :role  => role
  end
end
