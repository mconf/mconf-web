# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class JoinRequestUserAddedSenderWorker < BaseWorker
  @queue = :join_requests

  def self.perform(activity_id)
    activity = RecentActivity.find(activity_id)
    join_request = activity.trackable

    return if activity.notified

    if join_request.nil?
      Resque.logger.info "Invalid join request in a recent activity item: #{activity.inspect}"
    else
      Resque.logger.info "Sending join request no accept notification: #{join_request.inspect}"
      SpaceMailer.user_added_email(join_request.id).deliver
    end

    activity.notified = true
    activity.save!
  end
end
