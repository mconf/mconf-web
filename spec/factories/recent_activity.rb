# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

FactoryGirl.define do
  factory :recent_activity do |ra|
    ra.notified false
  end

  factory :space_join_activity, parent: :recent_activity do |ra|
    ra.association :owner, factory: :space
    ra.trackable_type "Space"
    ra.key "space.accept"
  end

  factory :space_decline_activity, parent: :recent_activity do |ra|
    ra.association :owner, factory: :space
    ra.trackable_type "Space"
    ra.key "space.decline"
  end

  factory :join_request_request_activity, parent: :recent_activity do |ra|
    ra.association :owner, factory: :space
    ra.association :trackable, factory: :join_request
    ra.key "join_request.request"
  end

  factory :join_request_invite_activity, parent: :recent_activity do |ra|
    ra.association :owner, factory: :space
    ra.association :trackable, factory: :join_request
    ra.key "join_request.invite"
  end
end
