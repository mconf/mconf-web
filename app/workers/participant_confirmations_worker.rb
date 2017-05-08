# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class ParticipantConfirmationsWorker < BaseWorker

  # Finds all unsent participant confirmations
  def self.perform
    confirmations = ParticipantConfirmation.where(email_sent_at: [nil])
    confirmations.each do |confirmation|
      Queue::High.enqueue(ParticipantConfirmationsWorker, :confirmation_sender, confirmation.id)
    end
  end

  # Sends a notification to the user with id `user_id` that he was approved.
  def self.confirmation_sender(pc_id)
    pc = ParticipantConfirmation.find(pc_id)

    if pc.email_sent_at.blank?
      Resque.logger.info "Sending event confirmation email to email to #{pc.email}"
      ParticipantConfirmationMailer.confirmation_email(pc_id).deliver
      pc.email_sent_at = Time.new
      pc.save!
    end
  end
end
