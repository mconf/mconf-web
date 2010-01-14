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

class AdmissionObserver < ActiveRecord::Observer
   def after_create(admission)
     case admission
     when Invitation
       Informer.deliver_invitation(admission)       
     when JoinRequest
       Informer.deliver_join_request(admission) 
     when EventInvitation
       Informer.deliver_event_invitation(admission)
     end
   end

   def after_update(admission)
     case admission
     when Invitation
       Informer.deliver_processed_invitation(admission)   
     when JoinRequest
       Informer.deliver_processed_join_request(admission)
     when EventInvitation
       Participant.create({:user => admission.candidate, :email => admission.email, :event_id => admission.event_id, :attend => admission.accepted})
     end if admission.recently_processed?
   end

end
