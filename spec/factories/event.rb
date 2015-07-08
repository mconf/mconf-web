# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :event, :class => MwebEvents::Event do |e|
    e.sequence(:name) { Forgery::Name.first_name }
    e.description { Forgery::LoremIpsum.paragraph }
    e.summary { Forgery::LoremIpsum.characters 140 }
    e.time_zone { Forgery::Time.zone }
    e.location { Forgery::Address.city }
    e.address { Forgery::Address.street_address }
    e.social_networks { MwebEvents::SOCIAL_NETWORKS.sample(3) }
    e.start_on { Time.now + 2.hours }
    e.end_on { Time.now + 4.hours }
  end
end
