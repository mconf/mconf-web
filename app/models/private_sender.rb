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
    debugger
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
