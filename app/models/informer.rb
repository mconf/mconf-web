#This class is the one in charge of informing users through the addecuate method
#private message or email in this version
class Informer
  
  
  def self.deliver_invitation(admission)
    if !admission.candidate || admission.candidate.notification == User::NOTIFICATION_VIA_EMAIL
       Notifier.deliver_invitation_email(admission)
     elsif admission.candidate.notification == User::NOTIFICATION_VIA_PM
         PrivateSender.invitation_message(admission)        
     end
   end
   
   
   def self.deliver_join_request(admission) 
     #in this case the deliver is to the admins of the space so we have to decide
     #whether using a Private Message or an Email depending on their profile
     admission.group.users(:role => 'Admin').each do |admin|
       if admin.notification == User::NOTIFICATION_VIA_EMAIL
         Notifier.deliver_join_request_email(admission, admin)
       elsif admin.notification == User::NOTIFICATION_VIA_PM
         PrivateSender.join_request_message(admission, admin)
       end
     end
   end
   
   
   def self.deliver_processed_invitation(admission)
       #in this case the deliver is to the admins of the space so we have to decide
       #whether using a Private Message or an Email depending on their profile
       admission.group.users(:role => 'Admin').each do |admin|
       if admin.notification == User::NOTIFICATION_VIA_EMAIL
         Notifier.deliver_processed_invitation_email(admission, admin)
       elsif admin.notification == User::NOTIFICATION_VIA_PM
         PrivateSender.processed_invitation_message(admission, admin)
       end
     end
   end
   
   
   def self.deliver_processed_join_request(admission)
     if !admission.candidate || admission.candidate.notification == User::NOTIFICATION_VIA_EMAIL
       Notifier.deliver_processed_join_request_email(admission)
     elsif admission.candidate.notification == User::NOTIFICATION_VIA_PM
       PrivateSender.processed_join_request_message(admission)
     end
   end
   
end
