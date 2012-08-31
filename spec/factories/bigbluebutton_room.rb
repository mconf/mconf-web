# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

FactoryGirl.define do
  factory :bigbluebutton_room do |r|
    r.sequence(:name) { |n| "Room #{n}" }
    r.association :server, :factory => :bigbluebutton_server
  end
end
