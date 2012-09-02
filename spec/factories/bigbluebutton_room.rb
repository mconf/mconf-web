# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

FactoryGirl.define do
  factory :bigbluebutton_room do |r|
    r.sequence(:meetingid) { |n| "meeting-#{n}-" + SecureRandom.hex(4) }
    r.sequence(:name) { |n| "Name#{n}" }
    r.attendee_password { Forgery(:basic).password :at_least => 5, :at_most => 16 }
    r.moderator_password { Forgery(:basic).password :at_least => 5, :at_most => 16 }
    r.welcome_msg { Forgery(:lorem_ipsum).sentences(2) }
    r.association :server, :factory => :bigbluebutton_server
    r.private false
    r.randomize_meetingid false
    r.sequence(:param) { |n| "meeting-#{n}" }
    r.external false
  end
end
