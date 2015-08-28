class Participant < ActiveRecord::Base
  belongs_to :owner, :polymorphic => true
  belongs_to :event

  validates :event_id, :presence => true
  validates :email, :presence => true, :email => true, :uniqueness => { :scope => :event_id }
  validates :owner_id, :uniqueness => { :scope => :event_id, :allow_nil => true }

  def email_taken?
    found = Participant.where(:email => email, :event_id => event).first
    found && email.present? && found.email == email
  end

end
