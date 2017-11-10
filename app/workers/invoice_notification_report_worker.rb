# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2017 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# Updates local invoices
class InvoiceNotificationReportWorker < BaseWorker
	def self.perform
    invoices_report
  end

  def self.invoices_report
    Invoice.where(notified: false).each do |invoice|
      date = (invoice.due_date - 1.month).strftime("%Y-%m")
      user = invoice.subscription.user
      user_id = invoice.subscription.user_id
      invoice_id = invoice.id

      if File.exists?(invoice.report_file_path)
        Resque.logger.info "Sending report invoice to #{user.name}."
        InvoiceMailer.invoice_report_email(user_id, invoice_id, date).deliver
        invoice.update_attributes(notified: true)
      end
    end
  end
end
