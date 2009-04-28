class InvitationObserver < ActiveRecord::Observer
   def after_create(invitation)
     Notifier.deliver_invitation_email(invitation)
   end
end