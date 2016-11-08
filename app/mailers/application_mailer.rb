# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# The mailer with all "general" emails that do not fit in the other more specific
# mailers.
class ApplicationMailer < BaseMailer

  def feedback_email(email, subject, body)
    I18n.with_locale(site_locale) do
      subject = "#{I18n.t("application_mailer.feedback_email.subject")}: #{subject}"
      @text = body
      @email = email
      create_email(Site.current.smtp_receiver, email, subject)
    end
  end
end
