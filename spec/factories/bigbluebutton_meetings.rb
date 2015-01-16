# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

FactoryGirl.define do
  factory :bigbluebutton_meeting do |m|
    m.sequence(:meetingid) { |n| "meeting-#{n}-" + SecureRandom.hex(4) }
    m.association :room, :factory => :bigbluebutton_room
    m.running false
    m.recorded false
    m.start_time { DateTime.now }
  end
end
