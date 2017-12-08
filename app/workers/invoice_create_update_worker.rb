# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2017 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# Updates local invoices
class InvoiceCreateUpdateWorker < BaseWorker
  def self.perform
    invoices_create
  end

  def self.invoices_create
    Subscription.not_on_trial.find_each do |subscription|

      # there are already invoices for this subscription
      if subscription.invoices.last.present?

        # the last invoice is for the current month
        if subscription.invoices.last.reference_this_month?
          subscription.invoices.last.update_unique_user_qty

        # the last invoice is not for this month
        else
          invoice = subscription.invoices.create(due_date: Invoice.next_due_date, flag_invoice_status: Invoice::INVOICE_STATUS[:local])
          invoice.update_unique_user_qty
        end

      # there are no invoices, create the first one
      else
        invoice = subscription.invoices.create(due_date: Invoice.next_due_date, flag_invoice_status: Invoice::INVOICE_STATUS[:local])
        invoice.update_unique_user_qty
        invoice.generate_consumed_days("create")
      end
    end
  end
end
