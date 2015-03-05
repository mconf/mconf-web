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
    notify_users_account_created
  end

  # Finds all users that registered and need to be approved and schedules a worker
  # to notify all users that could possibly approve him.
  def self.notify_admins_of_new_users
    # The Activities with keys user.created are used to inform the admins that a
    # new user has registered.
    activities = RecentActivity.where(trackable_type: 'User', notified: [nil, false], key: 'user.created')

    recipients = User.where(superuser: true).pluck(:id)
    unless recipients.empty?
      activities.each do |creation|
        # If user has already been approved, we don't need to send the notification.
        # That covers situations where the user is a superuser and also when the
        # user was automatically approved.
        if User.find(creation.trackable_id).approved
          creation.update_attribute(:notified, true)
        else
          Resque.enqueue(UserNeedsApprovalSenderWorker, creation.id, recipients)
        end
      end
    end
  end

  # The Activities with keys shibboleth.user.created and ldap.user.created are
  # used to send a notification to the user informing that he created an account
  def self.notify_users_account_created
    activities =
      RecentActivity.where(trackable_type: 'User', notified: [nil, false])
                    .where("`key` LIKE '%.user.created'")

    activities.each do |creation|
      UserMailer.registration_notification_email(creation.trackable_id).deliver
      creation.update_attributes(notified: true)
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
