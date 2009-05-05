class InvitationObserver < ActiveRecord::Observer
   def after_create(invitation)
     Notifier.deliver_invitation_email(invitation)

     if invitation.candidate
       m = PrivateMessage.new :title => "Invitation to #{ invitation.group.name }",
                              :body => "You have been invited to the space: #{ invitation.group.name }, please <a href=\"/invitations/#{ invitation.code }\">follow this link</a> in order to accept or deny the invitation"
       m.sender = invitation.introducer
       m.receiver = invitation.candidate
       m.save!
     end
   end
end
