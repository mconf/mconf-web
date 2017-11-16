# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.
require 'base64'

class SubscriptionMailer < BaseMailer

  def subscription_created_notification_email(subscription_creator_id, subscription_id)
    @subscription = Subscription.find(subscription_id)
    @user = User.find(subscription_creator_id)
    I18n.with_locale(default_email_locale(@user, nil)) do
      @subject = t("subscription_mailer.subscription_created_notification_email.subject",
        :id => @subscription.id).html_safe
      create_email(@user.email, Site.current.smtp_sender, @subject)
    end
  end

  def subscription_destroyed_notification_email(subscription_creator_id, subscription_id)
    @subscription = Subscription.find(subscription_id)
    @user = User.find(subscription_creator_id)
    I18n.with_locale(default_email_locale(@user, nil)) do
      @subject = t("subscription_mailer.subscription_destroyed_notification_email.subject",
        :id => @subscription.id).html_safe
      create_email(@user.email, Site.current.smtp_sender, @subject)
    end
  end
end
