# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# The mailer with methods inherited by all the other mailers in the application.
class BaseMailer < ActionMailer::Base
  include Resque::Mailer
  include Mconf::LocaleControllerModule

  self.prepend_view_path(File.join(Rails.root, 'app', 'mailers', 'views'))

  def error_handler(message, error, action, args)
    Rails.logger.error "Handling email error on #{self.class.name}"
    case action
    when "invitation_email"
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

  protected

  # Default method to create an email object
  def create_email(to, from, subject, headers=nil)
    I18n.with_locale(locale) do
      mail(:to => to,
           :subject => "[#{Site.current.name}] #{subject}",
           :from => "#{Site.current.name} <#{Site.current.smtp_sender}>",
           :headers => headers,
           :reply_to => from) do |format|
        format.html { render layout: 'mailers' }
      end
    end
  end

  def site_locale
    current = Site.current
    if current and !current.locale.blank?
      current.locale
    else
      I18n.default_locale
    end
  end

  # Try to get the receiver's time zone.
  # Falls back to the sender's time zone if the receiver doesn't have one.
  # If the sender doesn't have one also, will return the website's default.
  def default_email_time_zone(receiver, sender)
    if Mconf::Timezone.user_has_time_zone?(receiver)
      Mconf::Timezone.user_time_zone(receiver)
    else
      Mconf::Timezone.user_time_zone(sender)
    end
  end

  # Try to get the receiver's locale.
  # Falls back to the sender's locale if the receiver doesn't have one.
  # If the sender doesn't have one also, will return the website's default.
  def default_email_locale(receiver, sender)
    if user_has_locale?(receiver)
      get_user_locale(receiver, false)
    else
      get_user_locale(sender, false)
    end
  end

end
