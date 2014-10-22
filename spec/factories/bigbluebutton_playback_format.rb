# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

FactoryGirl.define do
  factory :bigbluebutton_playback_format do |r|
    r.association :recording, :factory => :bigbluebutton_recording
    r.association :playback_type, :factory => :bigbluebutton_playback_type
    r.url { "http://" + Forgery(:internet).domain_name + "/playback" }
    r.length { Forgery(:basic).number }
  end
end
