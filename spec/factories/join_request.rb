# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# TODO: this factory is throwing a warning, not sure exactly why:
#   DEPRECATION WARNING: You're trying to create an attribute `join_request_id'. Writing arbitrary attributes on a model is deprecated. Please just use `attr_writer` etc.
FactoryGirl.define do
  factory :join_request do |jr|
    jr.association :candidate, :factory => :user
    jr.association :introducer, :factory => :user
    jr.role { Role.find_by_name_and_stage_type('User', 'Space') }
    jr.email
    jr.request_type 'request'
  end

  factory :space_join_request, :parent => :join_request do |jr|
    jr.association :group, :factory => :space
  end

  factory :event_join_request, :parent => :join_request do |jr|
    jr.association :group, :factory => :event
  end
end
