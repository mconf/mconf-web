# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2017 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

FactoryGirl.define do
  factory :plan do |f|
    f.name Forgery::Name.company_name
    f.identifier Forgery::Name.company_name.downcase.tr(' ', '_')
    f.ops_token Forgery::CreditCard.number
    f.ops_type Plan::OPS_TYPES[:iugu]
    f.currency "BRL"
    f.interval_type "months"
    f.interval 1
  end
end


