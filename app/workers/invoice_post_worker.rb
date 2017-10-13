# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2017 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# Updates local invoices
class InvoicePostWorker < BaseWorker
  include dates_helper

  def self.perform
    invoices_post
  end

  def self.invoices_post
    Subscriptions.find_each do |sub|
      # check that we have a local invoice (there is a flag)
      # if local or pending then we can still post or update the subitem, else we will never change it.
      # possible flag values include local, pending, canceled, paid, expired.

      # this worker is going to be the one that updates the status flag, therefore even if it will not post an invoice
      # it still might update the status locally
    end
  end
end
