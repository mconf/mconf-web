# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class EventMailer < ApplicationMailer

  # Sends an invitation to an event.
  # Receives an Mconf::Invitation object in `invitation` and a User or email that will receive
  # this email in `to`.
  def invitation_mail(invitation, to)
    I18n.with_locale(get_user_locale(to, false)) do
      # Adjust the times to the target user's time zone. If he doesn't have a time zone set,
      # use the time zone of the sender.
      if Mconf::Timezone.user_has_time_zone?(to)
        time_zone = Mconf::Timezone.user_time_zone(to)
      else
        # will fall back to the website's time zone if the user doesn't have one
        time_zone = Mconf::Timezone.user_time_zone(invitation.from)
      end

      # Set time zone on event for sending
      invitation.event.time_zone = time_zone

      # Set the variables
      @invitation = invitation
      @event = invitation.event

      subject = t('event_mailer.invitation_mail.subject', :event => @event.name)
      attachments["#{@event.permalink}.ics"] = { :mime_type => 'text/calendar', :content => invitation.to_ical }

      if to.is_a?(User)
        create_email(to.email, invitation.from.email, subject)
      else
        create_email(to, invitation.from.email, subject)
      end
    end
  end

end
