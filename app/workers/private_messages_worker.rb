# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class PrivateMessagesWorker
  @queue = :private_messages

  # Finds all message recent activity and sends their users the message notifications
  def self.perform
    activities = RecentActivity.where notified: [nil,false], trackable_type: 'PrivateMessage', key: 'private_message.received'

    activities.each do |a|
      # receiver = a.owner
      # sender_name = a.parameters['sender_name']
      # digest = a.parameters['digest_type']
      # notification = a.parameters['notification_type']

      # still missing digest logic
      # Resque.logger "Sending email to #{receiver.email}. Message from #{sender.name}.\n"
      # TODO: actually send email

      a.notified = true
      a.save!
    end
  end

end
