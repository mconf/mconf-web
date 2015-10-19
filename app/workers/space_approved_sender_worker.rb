# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class SpaceApprovedSenderWorker < BaseWorker
  @queue = :space_notifications

  # Sends a notification to the space creator and all admins that the space with id `space_id` was approved.
  def self.perform(activity_id)
    activity = RecentActivity.find(activity_id)

    if !activity.notified? && activity.trackable.present?

      activity.trackable.admin_ids.each do |user_id|
        Resque.logger.info "Sending space approved email to #{user_id}"
        SpaceMailer.new_space_approved_email(user_id, activity.trackable_id).deliver
      end

      activity.update_attribute(:notified, true)
    end
  end

end
