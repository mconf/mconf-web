# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

FactoryGirl.define do
  factory :user, :class => User do |u|
    u.username
    u.email
    u.sequence(:_full_name) { |n| Forgery::Name.unique_full_name(n) }
    u.association :bigbluebutton_room
    u.association :profile
    u.created_at { Time.now }
    u.updated_at { Time.now }
    u.disabled false
    u.approved true
    u.superuser false
    u.receive_digest { User::RECEIVE_DIGEST_NEVER }
    u.notification { User::NOTIFICATION_VIA_EMAIL }
    u.password { Forgery::Basic.password :at_least => 6, :at_most => 16 }
    u.password_confirmation { |u2| u2.password }
    u.confirmed_at { Time.now }
    after(:create) { |u2| u2.confirm!; u2.reload }
  end

  # factory :user, :parent => :user_unconfirmed do |u|
  #   u.confirmed_at { Time.now }
  #   after(:create) { |u2| u2.confirm! }
  # end

  factory :superuser, :class => User, :parent => :user do |u|
    u.superuser true
  end
end
