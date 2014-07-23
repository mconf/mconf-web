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
  def invitation_mail(invitation)

    @invitation = find_invitation(invitation)
    return if @invitation.nil?

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

    I18n.with_locale(get_user_locale(to, false)) do
      # Adjust the times to the target user's time zone. If he doesn't have a time zone set,
      # use the time zone of the sender.
      if Mconf::Timezone.user_has_time_zone?(to)
        time_zone = Mconf::Timezone.user_time_zone(to)
      else
        # will fall back to the website's time zone if the user doesn't have one
        time_zone = Mconf::Timezone.user_time_zone(@invitation.sender)
      end
      @invitation.starts_on = @invitation.starts_on.in_time_zone(time_zone) unless @invitation.starts_on.blank?
      @invitation.ends_on = @invitation.ends_on.in_time_zone(time_zone) unless @invitation.ends_on.blank?

      subject = t('web_conference_mailer.invitation_mail.subject', :name => @invitation.sender.full_name)
      attachments['meeting.ics'] = { :mime_type => 'text/calendar', :content => @invitation.to_ical }

      if to.is_a?(User)
        create_email(to.email, @invitation.sender.email, subject)
      else
        create_email(to, @invitation.sender.email, subject)
      end
    end
  end

  def error_handler(message, error, action, args)
    Rails.logger.error "Handling email error on WebConferenceMailer"
    case action
    when "invitation_mail"
      invitation = Invitation.find_by_id(args[0])
      if invitation.nil?
        Rails.logger.error "Could not find the Invitation #{args[0]}, won't mark it as not sent"
      else
        # we just want to mark it as not sent, but raise the error afterwards
        invitation.result = false
        invitation.save!
        raise error
      end
    else
      raise error
    end
  end

  private

  def find_invitation(id)
    invitation = Invitation.find_by_id(id)
    if invitation.nil?
      Rails.logger.error "Aborting WebConferenceMailer because the invitation object was not found"
      Rails.logger.error "Parameters: invitation = #{id}"
      nil
    else
      invitation
    end
  end

  def find_invitation_recipient(invitation)
    if p_to.is_a?(String) # assume all strings are emails
      p_to
    else
      to = User.find_by_id(p_to)
      if to.nil?
        nil
      else
        to
      end
    end
  end

end
