# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class AdminMailer < BaseMailer

  def new_user_waiting_for_approval(admin_id, user_id)
    admin = User.find(admin_id)
    user = User.find(user_id)
    I18n.with_locale(default_email_locale(admin, nil)) do
      @user_name = user.name
      @user_email = user.email
      @subject = t('admin_mailer.new_user_waiting_for_approval.subject')
      create_email(admin.email, Site.current.smtp_sender, @subject)
    end
  end

  def new_user_approved(user_id)
    user = User.find(user_id)
    I18n.with_locale(default_email_locale(user, nil)) do
      @user_name = user.name
      @subject = t('admin_mailer.new_user_approved.subject')
      create_email(user.email, Site.current.smtp_sender, @subject)
    end
  end
end
