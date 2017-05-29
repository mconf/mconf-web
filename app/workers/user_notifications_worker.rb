# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# Finds all Invitation objects not sent yet and ready to be sent and schedules a
# worker to send them.
class UserNotificationsWorker < BaseWorker

  def self.perform
    notify_users_account_created
    notify_users_account_created_by_admin
    notify_users_account_cancelled
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
    activities = get_recent_activity
      .where(trackable_type: 'User', notified: [nil, false], key: 'user.created')

    recipients = User.superusers.pluck(:id)
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
            Queue::High.enqueue(UserNotificationsWorker, :needs_approval_sender, activity.id, recipients)
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
    activities = get_recent_activity
      .where(trackable_type: 'User', notified: [nil, false], key: keys)
    activities.each do |activity|
      Queue::High.enqueue(UserNotificationsWorker, :registered_sender, activity.id)
    end
  end

  # Finds all users that were created by a admin but not notified of it yet and schedules
  # a worker to notify them.
  def self.notify_users_account_created_by_admin
    activities = get_recent_activity
      .where(trackable_type: 'User', notified: [nil, false], key: 'user.created_by_admin')
    activities.each do |activity|
      Queue::High.enqueue(UserNotificationsWorker, :registered_by_admin_sender, activity.id)
    end
  end

  # Finds all users that were created by a admin but not notified of it yet and schedules
  # a worker to notify them.
  def self.notify_users_account_cancelled
    activities = get_recent_activity
      .where(trackable_type: 'User', notified: [nil, false], key: 'user.cancelled')
    activities.each do |activity|
      Queue::High.enqueue(UserNotificationsWorker, :cancelled_sender, activity.id)
    end
  end

  # Finds all users that were approved but not notified of it yet and schedules
  # a worker to notify them.
  def self.notify_users_after_approved
    activities = get_recent_activity
      .where trackable_type: 'User', key: 'user.approved', notified: [nil, false]
    activities.each do |activity|
      Queue::High.enqueue(UserNotificationsWorker, :approved_sender, activity.id)
    end
  end

  # Sends a notification to all recipients in the array of ids `recipient_ids`
  # informing that the user with id `user_id` needs to be approved.
  def self.needs_approval_sender(activity_id, recipient_ids)
    activity = get_recent_activity.find(activity_id)

    if !activity.notified?
      user_id = activity.trackable_id
      recipients = User.find(recipient_ids)

      recipients.each do |recipient|
        Resque.logger.info "Sending user needs approval email to #{recipient.inspect}, for user #{user_id}"
        AdminMailer.new_user_waiting_for_approval(recipient.id, user_id).deliver
      end

      activity.update_attribute(:notified, true)
    end
  end

  # Sends a notification to the user with id `user_id` that he was registered successfully.
  def self.registered_sender(activity_id)
    activity = get_recent_activity.find(activity_id)

    if !activity.notified?
      user_id = activity.trackable_id

      Resque.logger.info "Sending user registered email to #{user_id}"
      UserMailer.registration_notification_email(activity.trackable_id).deliver

      activity.update_attribute(:notified, true)
    end
  end

  # Sends a notification to the user with id `user_id` that he was registered successfully.
  def self.registered_by_admin_sender(activity_id)
    activity = get_recent_activity.find(activity_id)

    if !activity.notified?
      user_id = activity.trackable_id

      Resque.logger.info "Sending user registered email to #{user_id}"
      UserMailer.registration_by_admin_notification_email(activity.trackable_id).deliver

      activity.update_attribute(:notified, true)
    end
  end

  # Sends a notification to the user with id `user_id` that he was cancelled successfully.
  def self.cancelled_sender(activity_id)
    activity = get_recent_activity.find(activity_id)

    if !activity.notified?
      user_id = activity.trackable_id

      Resque.logger.info "Sending user cancelled email to #{user_id}"
      UserMailer.cancellation_notification_email(activity.trackable_id).deliver

      activity.update_attribute(:notified, true)
    end
  end

  # Sends a notification to the user with id `user_id` that he was approved.
  def self.approved_sender(activity_id)
    activity = get_recent_activity.find(activity_id)

    if !activity.notified?
      user_id = activity.trackable_id

      Resque.logger.info "Sending user approved email to #{user_id}"
      AdminMailer.new_user_approved(user_id).deliver

      activity.update_attribute(:notified, true)
    end
  end
end
