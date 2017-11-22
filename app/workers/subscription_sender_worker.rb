# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class SubscriptionSenderWorker < BaseWorker
  def self.perform(activity_id)
    activity = RecentActivity.find(activity_id)

    if !activity.notified? && activity.trackable.present?
      subscription_creator_name = activity.recipient.username
      subscription_id = activity.trackable_id

      if (activity.key == "subscription.created")
        Resque.logger.info "Sending subscription created to #{subscription_creator_name} with subscription ID: #{subscription_id}"
        SubscriptionMailer.subscription_created_notification_email(activity.recipient_id, subscription_id).deliver
      elsif (activity.key == "subscription.destroyed")
        Resque.logger.info "Sending subscription destroyed to #{subscription_creator_name} with subscription ID: #{subscription_id}"
        SubscriptionMailer.subscription_destroyed_notification_email(activity.recipient_id, subscription_id).deliver
      end
      activity.update_attributes(notified: true)
    end
  end
end
