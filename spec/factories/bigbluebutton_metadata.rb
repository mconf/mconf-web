# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

FactoryGirl.define do
  factory  :bigbluebutton_metadata do |r|
    r.association :owner, :factory => :bigbluebutton_recording
    r.sequence(:name) { |n| "#{Forgery(:name).first_name.downcase}-#{n}" }
    r.content { Forgery(:name).full_name }

    factory :bigbluebutton_room_metadata do |f|
      f.association :owner, :factory => :bigbluebutton_room
    end
  end
end
