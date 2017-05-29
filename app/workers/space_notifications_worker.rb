# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# Mostly for space approvals, find the newly created spaces and prepare notification objects
class SpaceNotificationsWorker < BaseWorker

  def self.perform
    if Site.current.require_space_approval
      notify_admins_of_spaces_pending_approval
      notify_space_admins_after_approved
    end
  end

  # Gets all spaces that were created and need approval, then schedules a worker to notify the global admins
  def self.notify_admins_of_spaces_pending_approval
    # The Activities with keys space.created are used to inform the admins that a new space was created.
    activities = get_recent_activity
      .where(trackable_type: 'Space', notified: [nil, false], key: 'space.create')

    recipients = User.superusers.pluck(:id)
    unless recipients.empty?
      activities.each do |activity|
        # If space has already been approved, we don't need to send the notification.
        space = Space.find_by(id: activity.trackable_id)
        if space.blank? || space.approved?
          activity.update_attribute(:notified, true)
        else
          Queue::High.enqueue(SpaceNotificationsWorker, :needs_approval_sender, activity.id, recipients)
        end
      end
    end
  end

  # Finds all spaces that were approved but not notified yet and schedules a worker.
  def self.notify_space_admins_after_approved
    activities = get_recent_activity
      .where trackable_type: 'Space', key: 'space.approved', notified: [nil, false]
    activities.each do |activity|
      Queue::High.enqueue(SpaceNotificationsWorker, :approved_sender, activity.id)
    end
  end

  # Sends a notification to all recipients in the array of ids `recipient_ids`
  # informing that the space with id `space_id` needs to be approved.
  def self.needs_approval_sender(activity_id, recipient_ids)
    activity = get_recent_activity.find(activity_id)

    if !activity.notified? && activity.trackable.present?
      space_id = activity.trackable_id
      recipients = User.find(recipient_ids)

      recipients.each do |recipient|
        Resque.logger.info "Sending space needs approval email to #{recipient.inspect}, for space #{space_id}"
        SpaceMailer.new_space_waiting_for_approval_email(recipient.id, space_id).deliver
      end

      activity.update_attribute(:notified, true)
    end
  end

  # Sends a notification to the space creator and all admins that the space with id `space_id` was approved.
  def self.approved_sender(activity_id)
    activity = get_recent_activity.find(activity_id)

    if !activity.notified? && activity.trackable.present?

      activity.trackable.admin_ids.each do |user_id|
        Resque.logger.info "Sending space approved email to #{user_id}"
        SpaceMailer.new_space_approved_email(user_id, activity.trackable_id).deliver
      end

      activity.update_attribute(:notified, true)
    end
  end
end
