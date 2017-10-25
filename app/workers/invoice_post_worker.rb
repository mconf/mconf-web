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
  end

  def self.invoices_post
    # possible flag values include local, pending, canceled, paid, expired.
    Invoice.where(flag_invoice_status: 'local') do |inv|
      inv.post_invoice_to_ops
      posted = inv.check_for_posted_invoices
      if posted.frist.present?
        update_attributes(flag_invoice_status: 'posted')
      end
    end
  end
end
