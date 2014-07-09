# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

FactoryGirl.define do
  factory :recent_activity do |ra|
  end

  factory :space_join_activity, :parent => :recent_activity do |ra|
    ra.association :owner, :factory => :space
    ra.trackable_type "Space"
    ra.key "space.join"
  end
end
