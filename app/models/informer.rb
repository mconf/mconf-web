# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

#This class is the one in charge of informing users through the adequate method
#private message or email in this version
class Informer

   def self.deliver_event_notification(event,receiver)
     if receiver.notification == User::NOTIFICATION_VIA_EMAIL
       #Notifier.event_notification_email(event,receiver)
     elsif receiver.notification == User::NOTIFICATION_VIA_PM
       PrivateSender.event_notification_message(event,receiver)
     end
   end

   def self.deliver_processed_invitation(admission)
     #in this case the deliver is to the admins of the space so we have to decide
     #whether using a Private Message or an Email depending on their profile
     admission.group.users(:role => 'Admin').each do |admin|
       if admin.notification == User::NOTIFICATION_VIA_EMAIL
         # Change it to the new format with Resque
         # Notifier.processed_invitation_email(admission, admin).deliver
       elsif admin.notification == User::NOTIFICATION_VIA_PM
         PrivateSender.processed_invitation_message(admission, admin)
       end
     end
   end

end
