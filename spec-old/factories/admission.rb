# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

FactoryGirl.define do
  factory :invitation do |m|
    m.sequence(:email) { |n| "invitation#{ n }@example.com" }
    m.association :group, :factory => :space
    m.association :introducer, :factory => :user
    m.comment "join!"
  end

  factory :candidate_invitation, :parent => :invitation do |m|
    m.association :candidate, :factory => :user
    m.email { |a| a.candidate.email }
  end

  factory :join_request do |m|
    m.association :candidate, :factory => :user
    m.email { |a| a.candidate.email }
    m.association :group, :factory => :space
    m.comment "approve me!"
  end
end

