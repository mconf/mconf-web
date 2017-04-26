# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class TrialNotificationsMailer < BaseMailer

  def ending_soon(user_id)
    user = User.find(user_id)

    # make sure the email wasn't already sent
    if user.trial_ending_soon_email.blank? && !user.trial_ended?
      I18n.with_locale(default_email_locale(user, nil)) do
        @user = user
        subject = t('trial_notifications_mailer.ending_soon.subject')
        create_email(user.email, Site.current.smtp_sender, subject)
      end
    end
  end

  def ended(user_id)
    user = User.find(user_id)

    # make sure the email wasn't already sent
    if user.trial_ended_email.blank? && user.trial_ended?
      I18n.with_locale(default_email_locale(user, nil)) do
        @user = user
        subject = t('trial_notifications_mailer.ended.subject')
        create_email(user.email, Site.current.smtp_sender, subject)
      end
    end
  end
end
