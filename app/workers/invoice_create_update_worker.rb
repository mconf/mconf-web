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
    Subscription.find_each do |subscription|
      if sub.user.trial_ended?

        # There is one and it is for this month
        if subscription.invoices.last.present? && subscription.invoices.last.due_date.to_date.month == (Date.today).month
          # We give a post command to the old invoice
          secondtolast = subscription.invoices.offset(1).last
          if secondtolast.present?
            Queue::High.enqueue(InvoicePostWorker, :perform, secondtolast.id)
          end

          subscription.invoices.last.update_unique_user_qty
        
        # There is none and is gonna be the first
        elsif !subscription.invoices.last.present?
          invoice = subscription.invoices.create(due_date: (DateTime.now.change({day: 10})), flag_invoice_status: "local")
          invoice.update_unique_user_qty
          invoice.generate_consumed_days("create")
        
        # There are invoices but not for this month
        else
          # We give a post command to the old invoice
          secondtolast = subscription.invoices.offset(1).last
          if secondtolast.present?
            Queue::High.enqueue(InvoicePostWorker, :perform, secondtolast.id)
          end

          invoice = subscription.invoices.create(due_date: (DateTime.now.change({day: 10})), flag_invoice_status: "local")
          invoice.update_unique_user_qty
        end
      end
    end
  end
end
