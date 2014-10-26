# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class JoinRequestInviteNotificationWorker
  @queue = :join_requests

  # Finds the join request associated with the activity in `activity_id` and sends
  # a notification to the user that he/she was invited to join the space.
  # Marks the activity as notified.
  def self.perform(activity_id)
    activity = RecentActivity.find(activity_id)
    join_request = activity.trackable

    Resque.logger.info "Sending join request invite notification: #{join_request.inspect}"
    SpaceMailer.invitation_email(join_request.id).deliver

    activity.notified = true
    activity.save!
  end

end
