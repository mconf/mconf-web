# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# The mailer with methods inherited by all the other mailers in the application.
class BaseMailer < ActionMailer::Base
  include Resque::Mailer
  include Mconf::LocaleControllerModule

  self.prepend_view_path(File.join(Rails.root, 'app', 'mailers', 'views'))

  add_template_helper(ApplicationHelper)
  add_template_helper(DatesHelper)
  add_template_helper(EmailHelper)

  protected

  # Default method to create an email object
  def create_email(to, from, subject, headers=nil)
    # set variables for views
    caller = BaseMailer.get_caller_name(caller_locations(1,1)[0])
    @mailer_name = caller[0]
    @mail_name = caller[1]

    I18n.with_locale(locale) do
      mail(:to => to,
           :subject => subject,
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

  # Returns an array with the class and method that called the method that is calling
  # this method (o.o'). Call with:
  #   get_caller_name(caller_locations(1,1)[0])
  def self.get_caller_name(caller_obj)
    file = caller_obj.absolute_path # e.g. /vagrant/app/mailers/web_conference_mailer.rb
    file = File.basename(file).gsub(/\..*/, '')
    method = caller_obj.base_label # e.g. invitation_email
    # "#{file}##{method}"
    [file, method]
  end
end
