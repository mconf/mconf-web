# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2017 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

FactoryGirl.define do
  factory :subscription do |f|
    f.association :plan, :factory => :plan
    f.association :user, :factory => :user
    f.customer_token Forgery::CreditCard.number
    f.subscription_token Forgery::CreditCard.number
    f.pay_day (Time.now+1.month).strftime('%Y/%m/%d')
    f.cpf_cnpj "658.753.830-46"
    f.address Forgery::Address.street_name
    f.number Forgery::Address.street_number
    f.zipcode "91509-900"
    f.city  Forgery::Address.city
    f.province Forgery::Address.province
    f.district Forgery::Address.province
    f.country Forgery::Address.country
  end
end
