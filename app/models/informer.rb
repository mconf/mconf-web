# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

#This class is the one in charge of informing users through the adequate method
#private message or email in this version
class Informer


  def self.deliver_invitation(admission)
    if !admission.candidate || admission.candidate.notification == User::NOTIFICATION_VIA_EMAIL
       Notifier.delay.invitation_email(admission)
     elsif admission.candidate.notification == User::NOTIFICATION_VIA_PM
       PrivateSender.invitation_message(admission)
     end
   end


   def self.deliver_event_invitation(admission)
     if !admission.candidate || admission.candidate.notification == User::NOTIFICATION_VIA_EMAIL
       #Notifier.delay.event_invitation_email(admission)
     elsif admission.candidate.notification == User::NOTIFICATION_VIA_PM
       PrivateSender.event_invitation_message(admission)
     end
   end

   def self.deliver_event_notification(event,receiver)
     if receiver.notification == User::NOTIFICATION_VIA_EMAIL
       #Notifier.delay.event_notification_email(event,receiver)
     elsif receiver.notification == User::NOTIFICATION_VIA_PM
       PrivateSender.event_notification_message(event,receiver)
     end
   end

   def self.deliver_permission_update_notification(sender,receiver,stage,rol)
     if receiver.notification == User::NOTIFICATION_VIA_EMAIL
       Notifier.delay.permission_update_notification_email(sender,receiver,stage,rol)
     elsif receiver.notification == User::NOTIFICATION_VIA_PM
       PrivateSender.permission_update_notification_message(sender,receiver,stage,rol)
     end
   end

   def self.deliver_space_group_invitation(space,mail)
     Notifier.delay.space_group_invitation_email(space,mail)
   end

   def self.deliver_event_group_invitation(event,mail)
     Notifier.delay.event_group_invitation_email(event,mail)
   end

   def self.deliver_join_request(admission)
     #in this case the deliver is to the admins of the space so we have to decide
     #whether using a Private Message or an Email depending on their profile
     admission.group.users(:role => 'Admin').each do |admin|
       if admin.notification == User::NOTIFICATION_VIA_EMAIL
         Notifier.delay.join_request_email(admission, admin)
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
         Notifier.delay.processed_invitation_email(admission, admin)
       elsif admin.notification == User::NOTIFICATION_VIA_PM
         PrivateSender.processed_invitation_message(admission, admin)
       end
     end
   end


   def self.deliver_processed_join_request(admission)
     if !admission.candidate || admission.candidate.notification == User::NOTIFICATION_VIA_EMAIL
       Notifier.delay.processed_join_request_email(admission)
     elsif admission.candidate.notification == User::NOTIFICATION_VIA_PM
       PrivateSender.processed_join_request_message(admission)
     end
   end

end
