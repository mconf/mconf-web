# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class JoinRequestsWorker < BaseWorker

  # Finds all join requests with pending notifications and sends them
  def self.perform
    request_notifications
    invite_notifications
    processed_request_notifications
    user_added_notifications
  end

  # Goes through all activities for join requests created by admins inviting users to join a space
  # and enqueues a notification for each.
  def self.invite_notifications
    invites = get_recent_activity.where trackable_type: 'JoinRequest', key: 'join_request.invite', notified: [nil,false]
    invites.each do |activity|
      Queue::High.enqueue(JoinRequestsWorker, :invite_sender, activity.id)
    end
  end

  # Goes through all activities for join requests created by users to join a space and enqueues
  # a notification for each.
  def self.request_notifications
    requests = get_recent_activity.where trackable_type: 'JoinRequest', key: 'join_request.request', notified: [nil,false]
    requests.each do |activity|
      Queue::High.enqueue(JoinRequestsWorker, :request_sender, activity.id)
    end
  end

  # Goes through all activities for processed join requests for which the users have not been
  # notified yet, and enqueues a notification for each.
  def self.processed_request_notifications
    requests = get_recent_activity.where trackable_type: 'JoinRequest', key: ['join_request.accept', 'join_request.decline'], notified: [nil,false]
    requests = requests.all.reject do |req|
      jr = req.trackable

      # don't generate email for blank join requests, declined user requests or if the owner is not a join request
      !jr.is_a?(JoinRequest) || jr.blank? || (jr.is_request? && !jr.accepted?)
    end

    requests.each do |activity|
      Queue::High.enqueue(JoinRequestsWorker, :processed_request_sender, activity.id)
    end
  end

  def self.user_added_notifications
    joins = get_recent_activity.where trackable_type: 'JoinRequest', key: ['join_request.no_accept'], notified: [nil, false]

    joins.each do |activity|
      Queue::High.enqueue(JoinRequestsWorker, :user_added_sender, activity.id)
    end
  end

  # Finds the join request associated with the activity in `activity_id` and sends
  # a notification to the user that he/she was invited to join the space.
  # Marks the activity as notified.
  def self.invite_sender(activity_id)
    activity = get_recent_activity.find(activity_id)
    join_request = activity.trackable

    return if activity.notified

    if join_request.nil?
      Resque.logger.info "Invalid join request in a recent activity item: #{activity.inspect}"
    else
      Resque.logger.info "Sending join request invite notification: #{join_request.inspect}"
      SpaceMailer.invitation_email(join_request.id).deliver
    end

    activity.notified = true
    activity.save!
  end

  # Finds the join request associated with the activity in `activity_id` and sends
  # a notification to the admins of the space that a user wants to join the space.
  # Marks the activity as notified.
  def self.request_sender(activity_id)
    activity = get_recent_activity.find(activity_id)
    space = activity.owner

    return if activity.notified

    if space.nil?
      Resque.logger.info "Invalid space in a recent activity item: #{activity.inspect}"
    elsif !activity.trackable.present?
      Resque.logger.info "Invalid trackable in a recent activity item: #{activity.inspect}"
    else
      # notify each admin of the space
      space.admins.each do |admin|
        Resque.logger.info "Sending join request notification to: #{admin.inspect}"
        SpaceMailer.join_request_email(activity.trackable.id, admin.id).deliver
      end
    end

    activity.notified = true
    activity.save!
  end

  # Finds the join request associated with the activity in `activity_id` and sends
  # a notification to the users that the join request was accepted/declined.
  # Marks the activity as notified.
  def self.processed_request_sender(activity_id)
    activity = get_recent_activity.find(activity_id)
    join_request = activity.trackable

    return if activity.notified

    if join_request.is_request?
      Resque.logger.info "Sending processed join request notification: #{join_request.inspect}"
      SpaceMailer.processed_join_request_email(join_request.id).deliver
    else
      Resque.logger.info "Sending processed join request invitation notification: #{join_request.inspect}"
      SpaceMailer.processed_invitation_email(join_request.id).deliver
    end

    activity.notified = true
    activity.save!
  end

  def self.user_added_sender(activity_id)
    activity = get_recent_activity.find(activity_id)
    join_request = activity.trackable

    return if activity.notified

    if join_request.nil?
      Resque.logger.info "Invalid join request in a recent activity item: #{activity.inspect}"
    else
      Resque.logger.info "Sending join request no accept notification: #{join_request.inspect}"
      SpaceMailer.user_added_email(join_request.id).deliver
    end

    activity.notified = true
    activity.save!
  end
end
