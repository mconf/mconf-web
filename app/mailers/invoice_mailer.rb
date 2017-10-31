# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.
require 'base64'

class InvoiceMailer < BaseMailer
  def invoice_report_email(user_id, invoice_id, date)
    invoice = Invoice.find(invoice_id)
    @user = User.find(user_id)
    content = File.read(invoice.report_txt_file_path, encoding: 'UTF-8')
    I18n.with_locale(default_email_locale(@user, nil)) do
      @subject = t("invoice_mailer.subject").html_safe
      base64_string = Base64.encode64(content)
      attachments['invoice-report.txt'] = { mime_type: 'plain/text', encoding: 'base64', content: base64_string }
      create_email(@user.email, Site.current.smtp_sender, @subject)
    end
  end
end
