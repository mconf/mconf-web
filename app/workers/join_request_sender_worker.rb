# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class JoinRequestSenderWorker < BaseWorker
  @queue = :join_requests

  # Finds the join request associated with the activity in `activity_id` and sends
  # a notification to the admins of the space that a user wants to join the space.
  # Marks the activity as notified.
  def self.perform(activity_id)
    activity = RecentActivity.find(activity_id)
    space = activity.owner

    return if activity.notified

    if space.nil?
      Resque.logger.info "Invalid space in a recent activity item: #{activity.inspect}"
    else
      # notify each admin of the space
      space.admins.each do |admin|
        Resque.logger.info "Sending join request notification to: #{admin.inspect}"
        SpaceMailer.join_request_email(activity.trackable.id, admin.id).deliver
      end
    end

    activity.notified = true
    activity.save!
  end

end
