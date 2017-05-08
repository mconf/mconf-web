# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# Finds all Invitation objects not sent yet and ready to be sent and schedules a
# worker to send them.
class InvitationsWorker < BaseWorker

  def self.perform
    all_invitations
  end

  def self.all_invitations
    invitations = Invitation.where sent: false, ready: true
    invitations.each do |invitation|
      Queue::High.enqueue(InvitationsWorker, :invitation_sender, invitation.id)
    end
  end

  # Finds the target notification and sends it. Marks it as notified.
  def self.invitation_sender(invitation_id)
    invitation = Invitation.find(invitation_id)
    if !invitation.sent?
      result = invitation.send_invitation
      invitation.update_attributes(sent: true, result: result)
    end
  end
end
