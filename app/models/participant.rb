class Participant < ActiveRecord::Base
  include PublicActivity::Common

  belongs_to :owner, :polymorphic => true
  belongs_to :event

  validates :event_id, :presence => true
  validates :email, :presence => true, :email => true, :uniqueness => { :scope => :event_id }
  validates :owner_id, :uniqueness => { :scope => :event_id, :allow_nil => true }

  has_one :participant_confirmation

  # Ensure participants will never be found if events are disabled.
  default_scope -> {
    Participant.none unless Mconf::Modules.mod_enabled?('events')
  }

  # create a ParticipantConfirmation request if no user is associated with the participation
  after_create :create_participant_confirmation, if: :annonymous?

  def annonymous?
    !owner.present?
  end

  # If a user has a confirmation request, return that value. If it has none, the user is confirmed
  def email_confirmed?
    if participant_confirmation.present?
      participant_confirmation.confirmed?
    else
      true
    end
  end

  def email_taken?
    found = Participant.where(:email => email, :event_id => event).first
    found && email.present? && found.email == email
  end

  def new_activity key, user
    create_activity key, :owner => owner, :parameters => { :user_id => user.try(:id), :username => user.try(:name) }
  end

end
