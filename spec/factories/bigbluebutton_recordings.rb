# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

FactoryGirl.define do
  factory  :bigbluebutton_recording do |r|
    r.association :server, :factory => :bigbluebutton_server
    r.association :room, :factory => :bigbluebutton_room
    r.sequence(:recordid) { |n| "rec#{n}" + SecureRandom.hex(26) }
    r.meetingid { "meeting" + SecureRandom.hex(8) }
    r.sequence(:name) { |n| "Rec #{n}" }
    r.published true
    r.start_time { Time.now - rand(5).hours }
    r.end_time { Time.now + rand(5).hours }
    r.available true
  end
end
