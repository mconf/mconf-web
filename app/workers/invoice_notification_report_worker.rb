# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2017 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# Updates local invoices
class InvoiceNotificationReportWorker < BaseWorker
  def self.perform
    send_all_reports
  end

  def self.send_all_reports
    Invoice.where(notified: false).find_each do |invoice|
      date = (invoice.due_date - 1.month).strftime("%Y-%m")
      user = invoice.subscription.user

      if File.exists?(invoice.report_file_path)
        Queue::High.enqueue(InvoiceNotificationReportWorker, :send_report, invoice.id, user.id, date)
      end
    end
  end

  def self.send_report(invoice_id, user_id, date)
    invoice = Invoice.find_by(id: invoice_id)
    Resque.logger.info "Sending invoice report from date #{date} to #{user_id}"
    InvoiceMailer.invoice_report_email(user_id, invoice_id).deliver
    invoice.update_attributes(notified: true)
  end
end
