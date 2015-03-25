# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class ParticipantConfirmationMailer < BaseMailer

  def confirmation_email(id)
    @pc = ParticipantConfirmation.find(id)
    I18n.with_locale(default_email_locale(nil, nil)) do
      @email = @pc.email
      @event = @pc.participant.event.name
      @subject = t("participant_confirmation_mailer.confirmation_email.subject", event: @event)
      create_email(@email, Site.current.smtp_sender, @subject)
    end
  end

end
