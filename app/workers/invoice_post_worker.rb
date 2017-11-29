# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2017 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# Updates local invoices
class InvoicePostWorker < BaseWorker
  def self.perform
    invoices_post
    invoices_sync
  end

  def self.invoices_post
    # To send it to the OPS
    Invoice.where(flag_invoice_status: "local").find_each do |invoice|
      invoice.post_invoice_to_ops
    end
  end

  def self.invoices_sync
    # To get payment data from OPS
    Invoice.where(flag_invoice_status: "posted").find_each do |invoice|
      unless invoice.invoice_url.present?
        invoice.get_invoice_payment_data
      end
    end
  end
end
