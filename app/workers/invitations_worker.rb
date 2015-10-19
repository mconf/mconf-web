# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# Finds all Invitation objects not sent yet and ready to be sent and schedules a
# worker to send them.
class InvitationsWorker < BaseWorker
  @queue = :invitations

  def self.perform
    all_invitations
  end

  def self.all_invitations
    invitations = Invitation.where sent: false, ready: true
    invitations.each do |invitation|
      Resque.enqueue(InvitationSenderWorker, invitation.id)
    end
  end

end
