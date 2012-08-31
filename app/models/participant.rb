# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class Participant < ActiveRecord::Base
  belongs_to :event
  belongs_to :user
  
  validates_uniqueness_of :user_id,
                          :scope => [ :event_id]
                        
  validates_uniqueness_of :email,
                          :scope => [ :event_id]
                          
  after_create do |participant|
    invitation = participant.event.invitations.select{|e| e.candidate == participant.user or e.email == participant.user.email}.first
    if invitation && !invitation.processed?
      invitation.processed_at = Time.now
      participant.attend? ? invitation.accepted = true : invitation.accepted = false
      invitation.save
    end
  end
end