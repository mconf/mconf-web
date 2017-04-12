# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

FactoryGirl.define do
  factory :profile do |p|
    p.city Forgery::Address.city
    p.country Forgery::Address.country
    p.organization Forgery::Name.company_name
    p.description Forgery::LoremIpsum.sentence
    p.url "http://#{Forgery::Internet.domain_name}"
    sequence(:full_name) { |n| Forgery::Name.unique_full_name(n) }
  end
end
