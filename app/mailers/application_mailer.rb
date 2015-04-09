# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
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
      create_email(Site.current.smtp_sender, email, subject)
    end
  end

  def digest_email(receiver_id, posts, news, attachments, events, inbox)
    receiver = User.find(receiver_id)
    I18n.with_locale(get_user_locale(receiver, false)) do
      @posts = Post.find(posts)
      @news = News.find(news)
      @attachments = Attachment.find(attachments)
      @events = MwebEvents::Event.find(events)
      @inbox = PrivateMessage.find(inbox)
      if receiver.receive_digest == User::RECEIVE_DIGEST_DAILY
        @type = t('email.digest.type.daily')
      else
        @type = t('email.digest.type.weekly')
      end
      @subject = t('email.digest.title', :type => @type)
      @signature  = Site.current.signature_in_html

      create_email(receiver.email, nil, @subject)
    end
  end
end
