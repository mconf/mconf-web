# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class ParticipantConfirmationsWorker < BaseWorker
  @queue = :participant_confirmations

  # Finds all unsent participant confirmations
  def self.perform
    confirmations = ParticipantConfirmation.where(email_sent_at: [nil])
    confirmations.each do |confirmation|
      Resque.enqueue(ParticipantConfirmationsSenderWorker, confirmation.id)
    end
  end
end
