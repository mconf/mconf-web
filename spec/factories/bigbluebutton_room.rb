# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

FactoryGirl.define do
  factory :bigbluebutton_room do |r|
    # meetingid with a random factor to avoid duplicated ids in consecutive test runs
    r.sequence(:meetingid) { |n| "meeting-#{n}-" + SecureRandom.hex(4) }

    r.sequence(:name) { |n| "Name#{n}" }
    r.attendee_key { Forgery(:basic).password :at_least => 10, :at_most => 16 }
    r.moderator_key { Forgery(:basic).password :at_least => 10, :at_most => 16 }
    r.attendee_api_password { SecureRandom.uuid }
    r.moderator_api_password { SecureRandom.uuid }
    r.welcome_msg { Forgery(:lorem_ipsum).sentences(2) }
    r.private false
    r.sequence(:slug) { |n| "meeting-#{n}" }
    r.external false
    r.record_meeting false
    r.duration 0
    r.sequence(:voice_bridge) { |n| "7#{n.to_s.rjust(4, '0')}" }
    r.dial_number { SecureRandom.random_number(9999999).to_s }
    r.sequence(:logout_url) { |n| "http://bigbluebutton#{n}.test.com/logout" }
    r.sequence(:max_participants) { |n| n }
    r.create_time { Time.now.to_i + rand(999999) }

    after(:create) do |r|
      r.updated_at = r.updated_at.change(:usec => 0)
      r.created_at = r.created_at.change(:usec => 0)
    end
  end
end
