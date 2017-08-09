# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2017 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# Updates local invoices
class InvoiceCreationWorker < BaseWorker

  def self.perform
    invoices_create
  end

  def self.invoices_create
    Subscriptions.find_each do |sub|
      if sub.user.trial_ended?
        if subscription.invoices.last.present? && subscription.invoices.last.due_date.to_date.month == (Date.today).month
          subscription.invoices.last.update_unique_user_qty
        else
          subscription.invoices.new(due_date: (DateTime.now)), flag_invoice_status: "local")
          subscription.invoices.last.update_unique_user_qty
        end
      end
    end
  end
end
