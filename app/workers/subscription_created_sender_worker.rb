# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class SubscriptionCreatedSenderWorker < BaseWorker
  def perform(activity_id)
    activity = RecentActivity.find(activity_id)

    if !activity.notified? && activity.trackable.present?

    end
  end
end
