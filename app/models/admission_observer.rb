class AdmissionObserver < ActiveRecord::Observer
   def after_create(admission)
     case admission
     when Invitation
       Notifier.deliver_invitation_email(admission)

       if admission.candidate
         m = PrivateMessage.new :title => "Invitation to #{ admission.group.name }",
                                :body => "You have been invited to the space: #{ admission.group.name }, please <a href=\"/invitations/#{ admission.code }\">accept or deny the invitation</a>. "
         m.sender = admission.introducer
         m.receiver = admission.candidate
         m.save!
       end
     when JoinRequest
       Notifier.deliver_join_request_email(admission)

       admission.group.users(:role => 'Admin').each do |admin|
         m = PrivateMessage.new :title => "Join Request to #{ admission.group.name }",
                                :body => "#{ admission.candidate.name } wants to participate in space #{ admission.group.name }, please <a href=\"/spaces/#{ admission.group.to_param }/admissions\">accept or deny the request</a>."
         m.sender = admission.candidate
         m.receiver = admin
         m.save!
       end
     end
   end

   def after_update(admission)
     case admission
     when Invitation
       Notifier.deliver_processed_invitation_email(admission)

       admission.group.users(:role => 'Admin').each do |admin|
         m = PrivateMessage.new :title => "Invitation to #{ admission.group.name } #{ admission.accepted? ? 'accepted' : 'discarded' }",
                                :body => "#{ admission.candidate.name } #{ admission.accepted? ? 'accepted' : 'discarted' } the invitation to join #{ admission.group.name }"

         m.sender = admission.candidate
         m.receiver = admin
         m.save!
       end
     when JoinRequest
       Notifier.deliver_processed_join_request_email(admission)

       m = PrivateMessage.new :title => "Join Request #{ admission.accepted? ? 'accepted' : 'discarded' }",
                              :body => "Your request to join #{ admission.group.name } was #{ admission.accepted? ? 'accepted' : 'discarded' }" 
       m.sender = admission.introducer
       m.receiver = admission.candidate
       m.save!
     end if admission.recently_processed?
   end

end
