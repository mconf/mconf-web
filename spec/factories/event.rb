# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

FactoryGirl.define do
  factory :event do |e|
    e.sequence(:name) { |n| Forgery::Name.unique_event_name(n) }
    e.description { Forgery::Basic.text }
    e.place { Forgery::Name.location }
    e.start_date { Time.now + 2.hours}
    e.end_date { Time.now + 4.hours}
    e.association :author, :factory => :user
    e.association :space, :factory => :space
  end
end
