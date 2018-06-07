
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
    notify_users_of_subscription_enabled
  end

  def self.notify_users_of_subscription_created
    activities = get_recent_activity
      .where(trackable_type: 'Subscription', notified: [nil, false], key: 'subscription.created')
    activities.each do |activity|
      Queue::High.enqueue(SubscriptionSenderWorker, :perform, activity.id)
    end
  end

  def self.notify_users_of_subscription_destroyed
    keys = ['subscription.destroy', 'subscription.disabled']
    activities = get_recent_activity
      .where(trackable_type: 'Subscription', notified: [nil, false], key: keys)
    activities.each do |activity|
      Queue::High.enqueue(SubscriptionSenderWorker, :perform, activity.id)
    end
  end

  def self.notify_users_of_subscription_enabled
    activities = get_recent_activity
      .where(trackable_type: 'Subscription', notified: [nil, false], key: 'subscription.enabled')
    activities.each do |activity|
      Queue::High.enqueue(SubscriptionSenderWorker, :perform, activity.id)
    end
  end

end
