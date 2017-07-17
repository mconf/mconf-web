# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2017 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# Sends emails related to the trial period.
class InvoiceCreationWorker < BaseWorker

  def self.perform
    invoices_create
    # invoice_send_usage_report (TODO: Send the names of the unique users for the month for review)
  end

  def self.invoices_create
    subscriptions = Subscriptions.where("pay_day < ?", (Time.now).strftime('%Y/%m/%d')) # only the ones past trial date
    subscriptions.each do |subscription|
      subscription.create_invoice
    end
  end

  # def self.invoice_send_usage_report
  #   mailer tasks
  # end

end
