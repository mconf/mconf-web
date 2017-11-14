
# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# For recently created and destroyed subscriptions.

class SubscriptionNotificationWorker < BaseWorker

  def self.perform
    notify_users_of_subscription_created
    notify_users_of_subscription_destroyed
  end

  def self.notify_users_of_subscription_created
    activities = RecentActivity
      .where(trackable_type: 'Subscription', notified: [nil, false], key: 'subscription.created')
    activities.each do |activity|
      Queue::High.enqueue(SubscriptionCreatedSenderWorker, :perform, activity.id)
    end
  end

  def self.notify_users_of_subscription_destroyed
    activities = RecentActivity
      .where(trackable_type: 'Subscription', notified: [nil, false], key: 'subscription.destroyed')
    activities.each do |activity|
      Queue::High.enqueue(SubscriptionDestroyedSenderWorker, :perform, activity.id)
    end
  end
end
