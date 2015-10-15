# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class SpaceNeedsApprovalSenderWorker < BaseWorker
  @queue = :space_notifications

  # Sends a notification to all recipients in the array of ids `recipient_ids`
  # informing that the space with id `space_id` needs to be approved.
  def self.perform(activity_id, recipient_ids)
    activity = RecentActivity.find(activity_id)

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

end
