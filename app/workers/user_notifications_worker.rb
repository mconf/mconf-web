# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# Finds all Invitation objects not sent yet and ready to be sent and schedules a
# worker to send them.
class UserNotificationsWorker
  @queue = :user_notifications

  def self.perform
    if Site.current.require_registration_approval
      notify_admins_of_new_users
      notify_users_after_approved
    end
  end

  # Finds all users that registered and need to be approved and schedules a worker
  # to notify all users that could possibly approve him.
  def self.notify_admins_of_new_users
    activities = RecentActivity.where trackable_type: 'User', key: 'user.created', notified: [nil, false]
    # users = User.where(approved: false, needs_approval_notification_sent_at: nil)
    recipients = User.where(superuser: true).pluck(:id)
    unless recipients.empty?
      activities.each do |creation|
        unless User.find(creation.owner_id).superuser
          Resque.enqueue(UserNeedsApprovalSenderWorker, creation.id, recipients)
        end
      end
    end
  end

  # Finds all users that were approved but not notified of it yet and schedules
  # a worker to notify them.
  def self.notify_users_after_approved
    activities = RecentActivity.where trackable_type: 'User', key: 'user.approved', notified: [nil, false]
    activities.each do |approval|
      Resque.enqueue(UserApprovedSenderWorker, approval.id)
    end
  end

end
