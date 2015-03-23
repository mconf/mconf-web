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
    notify_users_account_created
    notify_users_account_created_by_admin
    if Site.current.require_registration_approval
      notify_admins_of_users_pending_approval
      notify_users_after_approved
    end
  end

  # Finds all users that registered and need to be approved and schedules a worker
  # to notify all users that could possibly approve him.
  def self.notify_admins_of_users_pending_approval
    # The Activities with keys user.created are used to inform the admins that a
    # new user has registered.
    activities = RecentActivity
      .where(trackable_type: 'User', notified: [nil, false], key: 'user.created')

    recipients = User.where(superuser: true).pluck(:id)
    unless recipients.empty?
      activities.each do |activity|
        # If user has already been approved, we don't need to send the notification.
        # That covers situations where the user is a superuser and also when the
        # user was automatically approved.
        user = User.find_by(id: activity.trackable_id)
        if user
          if user.approved?
            activity.update_attribute(:notified, true)
          else
            Resque.enqueue(UserNeedsApprovalSenderWorker, activity.id, recipients)
          end
        end
      end
    end
  end

  # The activities with keys `shibboleth.user.created` and `ldap.user.created` are
  # used to send a notification to the user informing that he has a new account
  # created by a login via shibboleth or LDAP.
  # This is not used for normal registrations! In these cases it's devise that sends
  # the emails.
  def self.notify_users_account_created
    keys = ['shibboleth.user.created', 'ldap.user.created']
    activities = RecentActivity
      .where(trackable_type: 'User', notified: [nil, false], key: keys)
    activities.each do |activity|
      Resque.enqueue(UserRegisteredSenderWorker, activity.id)
    end
  end

  # Finds all users that were created by a admin but not notified of it yet and schedules
  # a worker to notify them.
  def self.notify_users_account_created_by_admin
    activities = RecentActivity
      .where(trackable_type: 'User', notified: [nil, false], key: 'user.created_by_admin')
    activities.each do |activity|
      Resque.enqueue(UserRegisteredByAdminSenderWorker, activity.id)
    end
  end

  # Finds all users that were approved but not notified of it yet and schedules
  # a worker to notify them.
  def self.notify_users_after_approved
    activities = RecentActivity
      .where trackable_type: 'User', key: 'user.approved', notified: [nil, false]
    activities.each do |activity|
      Resque.enqueue(UserApprovedSenderWorker, activity.id)
    end
  end


end
