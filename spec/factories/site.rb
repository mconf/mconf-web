# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

FactoryGirl.define do
  factory :site do |f|
    f.name Forgery::Name.company_name
    f.description Forgery::Basic.text
    f.domain Forgery::Internet.domain_name
    f.smtp_login Forgery::Internet.user_name
    f.locale "en"
    f.ssl false
    f.exception_notifications false
    f.signature Forgery::Name.company_name
    f.shib_enabled false
    f.chat_enabled false
  end
end
