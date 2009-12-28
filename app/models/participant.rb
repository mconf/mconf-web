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