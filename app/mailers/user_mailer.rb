# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class UserMailer < BaseMailer

  def registration_notification_email(user_id)
    user = User.find(user_id)
    I18n.with_locale(default_email_locale(user, nil)) do
      @user_name = user.name
      @subject = t("user_mailer.registration_notification_email.subject")
      create_email(user.email, Site.current.smtp_sender, @subject)
    end
  end

  def registration_by_admin_notification_email(user_id)
    user = User.find(user_id)
    I18n.with_locale(default_email_locale(user, nil)) do
      @user_name = user.name
      @subject = t("user_mailer.registration_by_admin_notification_email.subject")
      create_email(user.email, Site.current.smtp_sender, @subject)
    end
  end

  def cancellation_notification_email(user_id)
    user = User.with_disabled.find(user_id)
    I18n.with_locale(default_email_locale(user, nil)) do
      @user = user
      @subject = t("user_mailer.cancellation_notification_email.subject")
      email = user.enabled_parse(user.email)
      create_email(email, Site.current.smtp_sender, @subject)
    end
  end

end
