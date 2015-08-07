# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

FactoryGirl.define do
  factory :join_request do |jr|
    jr.association :candidate, :factory => :user
    jr.association :introducer, :factory => :user
    jr.role { Role.find_by(name: 'User', stage_type: 'Space') }
    jr.email
    jr.request_type JoinRequest::TYPES[:request]
    jr.comment { Forgery::LoremIpsum.paragraph }
  end

  factory :join_request_invite, :parent => :join_request do |jr|
    jr.request_type JoinRequest::TYPES[:invite]
  end

  factory :space_join_request, :parent => :join_request do |jr|
    jr.association :group, :factory => :space
  end

  factory :space_join_request_invite, :parent => :space_join_request do |jr|
    jr.request_type JoinRequest::TYPES[:invite]
  end
end
