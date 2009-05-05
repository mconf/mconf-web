class AdmissionObserver < ActiveRecord::Observer
   def after_create(admission)
     if admission.is_a?(Invitation)
       Notifier.deliver_invitation_email(admission)

       if admission.candidate
         m = PrivateMessage.new :title => "Invitation to #{ admission.group.name }",
                                :body => "You have been invited to the space: #{ admission.group.name }, please <a href=\"/invitations/#{ admission.code }\">follow this link</a> in order to accept or deny the invitation"
         m.sender = admission.introducer
         m.receiver = admission.candidate
         m.save!
       end
     elsif admission.is_a?(JoinRequest)

       admission.group.users(:role => 'Admin').each do |admin|
         m = PrivateMessage.new :title => "Join Request to #{ admission.group.name }",
                                :body => "#{ admission.candidate.name } wants to participate in space #{ admission.group.name }, please <a href=\"/spaces/#{ admission.group.to_param }/admissions\">follow this link</a> in order to accept or deny the request"
         m.sender = admission.candidate
         m.receiver = admin
         m.save!
       end
       Notifier.deliver_join_request_email(admission)
     end
   end
end
