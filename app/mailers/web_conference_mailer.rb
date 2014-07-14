# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class WebConferenceMailer < ApplicationMailer

  # Sends an invitation to a web conference.
  # Receives an Mconf::Invitation object in `invitation` and a User or email that will receive
  # this email in `to`.
  def invitation_mail(invitation, to)

    to = (u = User.find_by_email(to)) ? u : to

    # Converting a received string hash into a Mconf Invitation
    @invitation = Mconf::Invitation.new
    @invitation.title = invitation["title"]
    @invitation.description = invitation["description"]
    @invitation.starts_on = invitation["starts_on"].to_datetime
    @invitation.ends_on = invitation["ends_on"].to_datetime
    @invitation.url = invitation["url"]
    @invitation.from = User.find(invitation["from"]["id"])
    @invitation.room = BigbluebuttonRoom.find(invitation["room"]["id"])

    I18n.with_locale(get_user_locale(to, false)) do
      # clone it because we need to change a few things
      # @invitation = invitation.clone

      # Adjust the times to the target user's time zone. If he doesn't have a time zone set,
      # use the time zone of the sender.
      if Mconf::Timezone.user_has_time_zone?(to)
        time_zone = Mconf::Timezone.user_time_zone(to)
      else
        # will fall back to the website's time zone if the user doesn't have one
        time_zone = Mconf::Timezone.user_time_zone(@invitation.from)
      end
      @invitation.starts_on = @invitation.starts_on.in_time_zone(time_zone) if @invitation.starts_on
      @invitation.ends_on = @invitation.ends_on.in_time_zone(time_zone) if @invitation.ends_on

      subject = t('web_conference_mailer.invitation_mail.subject', :name => @invitation.from.full_name)
      attachments['meeting.ics'] = { :mime_type => 'text/calendar', :content => @invitation.to_ical }
      #attachments['meeting.ics'] = invitation.to_ical

      if to.is_a?(User)
        create_email(to.email, @invitation.from.email, subject)
      else
        create_email(to, @invitation.from.email, subject)
      end
    end
  end

end
