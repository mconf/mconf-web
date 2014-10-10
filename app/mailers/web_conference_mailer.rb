# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class WebConferenceMailer < BaseMailer

  # Sends an invitation to a web conference.
  # Receives the ID of an Invitation object in `invitation` and gets everything else
  # from this object.
  def invitation_email(invitation)
    @invitation = Invitation.find(invitation)

    if @invitation.recipient.nil?
      if @invitation.recipient_email.nil?
        Rails.logger.error "Aborting WebConferenceMailer because the destination user was not found"
        Rails.logger.error "Invitation: #{@invitation.inspect}"
        return
      else
        to = @invitation.recipient_email
      end
    else
      to = @invitation.recipient
    end

    locale = default_email_locale(to, @invitation.sender)
    I18n.with_locale(locale) do
      @time_zone = default_email_time_zone(to, @invitation.sender)

      subject = t('web_conference_mailer.invitation_email.subject')
      attachments['meeting.ics'] = { :mime_type => 'text/calendar', :content => @invitation.to_ical }

      if to.is_a?(User)
        create_email(to.email, @invitation.sender.email, subject)
      else
        create_email(to, @invitation.sender.email, subject)
      end
    end
  end
end
