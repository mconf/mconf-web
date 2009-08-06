class Participant < ActiveRecord::Base
  belongs_to :event
  belongs_to :user
  
  validates_uniqueness_of :user_id,
                          :scope => [ :event_id]
                        
  validates_uniqueness_of :email,
                          :scope => [ :event_id]
                          
  after_create do |participant|
    invitation = participant.event.event_invitations.select{|e| e.candidate == participant.user or e.email == participant.user.email}.first
    if invitation && !invitation.processed?
      invitation.processed_at = Time.now
      participant.attend? ? invitation.accepted = true : invitation.accepted = false
      invitation.save
    end
  end
end