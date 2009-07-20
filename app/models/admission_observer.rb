class AdmissionObserver < ActiveRecord::Observer
   def after_create(admission)
     case admission
     when Invitation
       Informer.deliver_invitation(admission)       
     when JoinRequest
       Informer.deliver_join_request(admission) 
     end
   end

   def after_update(admission)
     case admission
     when Invitation
       Informer.deliver_processed_invitation(admission)   
     when JoinRequest
       Informer.deliver_processed_join_request(admission)
     end if admission.recently_processed?
   end

end
