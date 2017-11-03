# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2017 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# Updates local invoices
class InvoicePostWorker < BaseWorker
  def self.perform(invoice_id)
    invoices_post(invoice_id)
    invoices_sync(invoice_id)
  end

  def self.invoices_post(invoice_id)
    # possible flag values include local, pending, canceled, paid, expired.
    inv = Invoice.find_by(id: invoice_id)
    if inv.flag_invoice_status == 'local'
      inv.post_invoice_to_ops
    end
  end

  def self.invoices_sync(invoice_id)
    # possible flag values include local, pending, canceled, paid, expired.
    inv = Invoice.find_by(id: invoice_id)
    unless inv.invoice_url.present? || inv.flag_invoice_status != 'posted'
      inv.get_invoice_payment_data
    end
  end
end
