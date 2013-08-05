class JoinRequest < ActiveRecord::Base
  belongs_to :candidate, :class_name => "User", :foreign_key => 'candidate_id'
  belongs_to :introducer, :class_name => "User", :foreign_key => 'introducer_id'

  has_one :role

  validates :email, :presence => true, :email => true

  # The request can either be an invitation ('invite') or a 'request' for membership
  validates :request_type, :presence => true

  attr_writer :processed
  before_save :processed

  validates_uniqueness_of :candidate_id,
                          :scope => [ :group_id, :group_type, :processed_at ],
                          :allow_nil => true

  validates_uniqueness_of :email,
                          :scope => [ :group_id, :group_type, :processed_at ]

  validate :candidate_is_not_introducer

  # Has this Admission been processed?
  def processed?
    processed_at.present?
  end

  # Has this Admission been recently processed? (typically in this request)
  def recently_processed?
    @processed.present?
  end

  private

  def processed
    @processed && self.processed_at = Time.now.utc
  end

  def candidate_is_not_introducer
    if candidate == introducer
      errors.add(:base, I18n.t('admission.errors.candidate_equals_introducer'))
    end
  end
end
