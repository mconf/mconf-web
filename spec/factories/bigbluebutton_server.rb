# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

FactoryGirl.define do
  factory:bigbluebutton_server do |s|
    s.sequence(:name) { |n| "Server #{n}" }
    s.sequence(:url) { |n| "http://server#{n}/bigbluebutton/api" }
    s.sequence(:salt) { |n| "1234567890abcdefghijkl#{n}" }
    s.version "0.7"
  end
end
