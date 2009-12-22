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

#This class will compose all the mails that the application should send

class PrivateSender
  
  def self.invitation_message(invitation)
     m = PrivateMessage.new :title => "Invitation to #{ invitation.group.name }",
                            :body => "You have been invited to the space: #{ invitation.group.name }, please <a href=\"/invitations/#{ invitation.code }\">accept or deny the invitation</a>. "
     m.sender = invitation.introducer
     m.receiver = invitation.candidate
     m.save!
  end
  
  
  def self.event_invitation_message(invitation)
    m = PrivateMessage.new :title => I18n.t("invitation.subject",:space=>invitation.group.name,:username=>invitation.introducer.login),
      :body => invitation.comment.gsub('\'name\'',invitation.candidate.login) + "<br>" + I18n.t('invitation.ps',:url => 'http://' + Site.current.domain + '/event_invitations/' + invitation.code)
    m.sender = invitation.introducer
    m.receiver = invitation.candidate
    m.save!
  end
  
  
  def self.join_request_message(admission, receiver)    
      m = PrivateMessage.new :title => "Join Request to #{ admission.group.name }",
                             :body => "#{ admission.candidate.name } wants to participate in space #{ admission.group.name }, please <a href=\"/spaces/#{ admission.group.to_param }/admissions\">accept or deny the request</a>."
      m.sender = admission.candidate
      m.receiver = receiver
      m.save!
  end
  
  
  def self.processed_invitation_message(admission, receiver)
        m = PrivateMessage.new :title => "Invitation to #{ admission.group.name } #{ admission.accepted? ? 'accepted' : 'discarded' }",
                               :body => "#{ admission.candidate.name } #{ admission.accepted? ? 'accepted' : 'discarted' } the invitation to join #{ admission.group.name }"

        m.sender = admission.candidate
        m.receiver = receiver
        m.save!
  end
  
  
  def self.processed_join_request_message(admission)
    m = PrivateMessage.new :title => "Join Request #{ admission.accepted? ? 'accepted' : 'discarded' }",
                           :body => "Your request to join #{ admission.group.name } was #{ admission.accepted? ? 'accepted' : 'discarded' }" 
    m.sender = admission.introducer
    m.receiver = admission.candidate
    m.save!
  end
  
end
