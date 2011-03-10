# -*- coding: utf-8 -*-
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

#This class is the one in charge of informing users through the adequate method
#private message or email in this version
class Informer
  
  
  def self.deliver_invitation(admission)
    if !admission.candidate || admission.candidate.notification == User::NOTIFICATION_VIA_EMAIL
       Notifier.invitation_email(admission).deliver
     elsif admission.candidate.notification == User::NOTIFICATION_VIA_PM
       PrivateSender.invitation_message(admission)        
     end
   end
   
   
   def self.deliver_event_invitation(admission)
     if !admission.candidate || admission.candidate.notification == User::NOTIFICATION_VIA_EMAIL
       Notifier.event_invitation_email(admission).deliver
     elsif admission.candidate.notification == User::NOTIFICATION_VIA_PM
       PrivateSender.event_invitation_message(admission)        
     end
   end
   
   def self.deliver_event_notification(event,receiver)
     if receiver.notification == User::NOTIFICATION_VIA_EMAIL
       Notifier.event_notification_email(event,receiver).deliver
     elsif receiver.notification == User::NOTIFICATION_VIA_PM
       PrivateSender.event_notification_message(event,receiver)
     end
   end
   
   def self.deliver_performance_update_notification(sender,receiver,stage,rol)
     if receiver.notification == User::NOTIFICATION_VIA_EMAIL
       Notifier.performance_update_notification_email(sender,receiver,stage,rol).deliver
     elsif receiver.notification == User::NOTIFICATION_VIA_PM
       PrivateSender.performance_update_notification_message(sender,receiver,stage,rol)
     end
   end
   
   def self.deliver_space_group_invitation(space,mail)
     Notifier.space_group_invitation_email(space,mail).deliver
   end
   
   def self.deliver_event_group_invitation(event,mail)
     Notifier.event_group_invitation_email(event,mail).deliver
   end      
   
   def self.deliver_join_request(admission) 
     #in this case the deliver is to the admins of the space so we have to decide
     #whether using a Private Message or an Email depending on their profile
     admission.group.users(:role => 'Admin').each do |admin|
       if admin.notification == User::NOTIFICATION_VIA_EMAIL
         Notifier.join_request_email(admission, admin).deliver
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
         Notifier.processed_invitation_email(admission, admin).deliver
       elsif admin.notification == User::NOTIFICATION_VIA_PM
         PrivateSender.processed_invitation_message(admission, admin)
       end
     end
   end
   
   
   def self.deliver_processed_join_request(admission)
     if !admission.candidate || admission.candidate.notification == User::NOTIFICATION_VIA_EMAIL
       Notifier.processed_join_request_email(admission).deliver
     elsif admission.candidate.notification == User::NOTIFICATION_VIA_PM
       PrivateSender.processed_join_request_message(admission)
     end
   end
   
end
