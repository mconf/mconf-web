# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# Sends emails related to the trial period.
class TrialNotificationsWorker < BaseWorker

  def self.perform
    trial_ended_mails
    ending_soon_mails
  end

  def self.ending_soon_mails
    start_at = DateTime.now
    end_at = start_at + 7.days # anything in the future, 7 days to send msg 7 days before the end
    expiring_next_7_days =
      User.where('trial_expires_at > ?', start_at).where('trial_expires_at <= ?', end_at)
    expiring_next_7_days.find_each do |user|
      if user.trial_ending_soon_email.blank?
        Queue::High.enqueue(TrialNotificationsWorker, :ending_soon_sender, user.id)
      end
    end
  end

  def self.ending_soon_sender(user_id)
    user = User.find(user_id)
    TrialNotificationsMailer.ending_soon(user.id).deliver if user.trial_ending_soon_email.blank?
  end


  def self.trial_ended_mails
    start_at = DateTime.now - 2.days # anything in the past, just used 2 days to restrict the search
    end_at = DateTime.now
    # TODO: what if it expired before -2.day?

    expiring_today =
      User.where('trial_expires_at >= ?', start_at).where('trial_expires_at <= ?', end_at)
    expiring_today.find_each do |user|
      if user.trial_ended_email.blank?
        Queue::High.enqueue(TrialNotificationsWorker, :ended_sender, user.id)
      end
    end
  end

  def self.ended_sender(user_id)
    user = User.find(user_id)
    TrialNotificationsMailer.ended(user.id).deliver if user.trial_ended_email.blank?
  end
end
