class ParticipantConfirmation < ActiveRecord::Base
  belongs_to :participant, :class_name => "MwebEvents::Participant"
  before_create :generate_token
  after_create :send_participant_confirmation

  delegate :email, to: :participant

  def generate_token
    self.token = SecureRandom.urlsafe_base64(16)
  end

  def to_param
    token
  end

  def confirm!
    update_attributes confirmed_at: Time.now
  end

  def confirmed?
    confirmed_at.present?
  end

  private
  def send_participant_confirmation
    ParticipantConfirmationMailer.confirmation_email(id).deliver!
  end
end
