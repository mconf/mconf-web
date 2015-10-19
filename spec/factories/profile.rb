# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

FactoryGirl.define do
  factory :profile do |p|
    p.visibility Profile::VISIBILITY.index(:public_fellows)
    p.city Forgery::Address.city
    p.country Forgery::Address.country
    p.organization Forgery::Name.company_name
    p.prefix_key "Mr."
    p.description Forgery::LoremIpsum.sentence
    p.skype Forgery::Internet.user_name
    p.im Forgery::Internet.email_address
    p.url "http://#{Forgery::Internet.domain_name}"
    p.full_name Forgery::Name.full_name
  end
end
