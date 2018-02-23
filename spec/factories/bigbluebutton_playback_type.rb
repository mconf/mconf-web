# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

FactoryGirl.define do
  factory :bigbluebutton_playback_type do |pbt|
    pbt.sequence(:identifier) { |n| "#{Forgery(:name).first_name.downcase}-#{n}" }
    pbt.visible true
    pbt.default false
    pbt.downloadable false
  end
end
