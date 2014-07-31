# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :event, :class => MwebEvents::Event do |e|
    e.sequence(:name) { Faker::Name.name }
    e.description { Faker::Lorem.paragraph 1, false, 0 }
    e.summary { Faker::Lorem.characters 140 }
    e.time_zone { Faker::Address.time_zone }
    e.location { Faker::Name.name }
    e.address { Faker::Address.street_address }
    e.social_networks { MwebEvents::SOCIAL_NETWORKS.sample(3) }
    e.start_on { Time.now + 2.hours }
    e.end_on { Time.now + 4.hours }
  end
end
