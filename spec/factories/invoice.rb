# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2017 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

FactoryGirl.define do
  factory :invoice do |f|
    f.association :subscription, :factory => :subscription
    f.invoice_token Forgery::CreditCard.number
    f.invoice_url "http://#{Forgery::Internet.domain_name}"
    f.flag_invoice_status Invoice::INVOICE_STATUS[:local]
    f.due_date (Time.now + 29.days).strftime('%Y/%m/%d')
    f.user_qty SecureRandom.random_number(6999)
    f.days_consumed SecureRandom.random_number(29)
    f.invoice_value SecureRandom.random_number(79)
    f.notified false
  end
end