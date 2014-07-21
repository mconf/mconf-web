# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class EventMailer < BaseMailer

  # Sends an invitation to an event.
  # Receives the ID of an Invitation object in `invitation` and the ID of a User or email
  # that will receive this email in `to`.
  def invitation_mail(p_invitation, p_to)

    @invitation = Invitation.find_by_id(p_invitation)
    if @invitation.nil?
      Rails.logger.error "Aborting EventMailer#invitation_mail because the invitation object was not found"
      Rails.logger.error "Parameters: invitation = #{p_invitation}"
      return
    end

    if p_to.is_a?(String) # assume all strings are emails
      to = p_to
    else
      to = User.find_by_id(p_to)
      if to.nil?
        Rails.logger.error "Aborting EventMailer#invitation_mail because the destination user was not found"
        Rails.logger.error "Parameters: to = #{p_to}"
        return
      end
    end

    I18n.with_locale(get_user_locale(to, false)) do
      # Adjust the times to the target user's time zone. If he doesn't have a time zone set,
      # use the time zone of the sender.
      if Mconf::Timezone.user_has_time_zone?(to)
        time_zone = Mconf::Timezone.user_time_zone(to)
      else
        # will fall back to the website's time zone if the user doesn't have one
        time_zone = Mconf::Timezone.user_time_zone(@invitation.from)
      end

      @event = @invitation.target

      # Set time zone on event for sending
      @event.time_zone = time_zone

      subject = t('event_mailer.invitation_mail.subject', :event => @event.name)
      attachments["#{@event.permalink}.ics"] = { :mime_type => 'text/calendar', :content => @invitation.to_ical }

      if to.is_a?(User)
        create_email(to.email, @invitation.from.email, subject)
      else
        create_email(to, @invitation.from.email, subject)
      end
    end
  end

end
