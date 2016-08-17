# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

FactoryGirl.define do
  factory  :bigbluebutton_room do |r|
    # meetingid with a random factor to avoid duplicated ids in consecutive test runs
    r.sequence(:meetingid) { |n| "meeting-#{n}-" + SecureRandom.hex(4) }

    r.association :server, :factory => :bigbluebutton_server
    r.sequence(:name) { |n| "Name#{n}" }
    r.attendee_key { Forgery(:basic).password :at_least => 10, :at_most => 16 }
    r.moderator_key { Forgery(:basic).password :at_least => 10, :at_most => 16 }
    r.attendee_api_password { SecureRandom.uuid }
    r.moderator_api_password { SecureRandom.uuid }
    r.welcome_msg { Forgery(:lorem_ipsum).sentences(2) }
    r.private false
    r.sequence(:param) { |n| "meeting-#{n}" }
    r.external false
    r.record_meeting false
    r.duration 0
  end
end
