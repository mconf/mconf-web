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
