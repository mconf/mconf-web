# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

FactoryGirl.define do
  factory :user do |u|
    u.sequence(:username) { |n| Forgery::Internet.unique_user_name(n) }
    u.sequence(:email) { |n| Forgery::Internet.unique_email_address(n) }
    u.sequence(:_full_name) { |n| Forgery::Name.unique_full_name(n) }
    u.association :bigbluebutton_room
    u.created_at { Time.now }
    u.updated_at { Time.now }
    u.confirmed_at { Time.now }
    u.disabled false
    u.superuser false
    u.receive_digest { User::RECEIVE_DIGEST_NEVER }
    u.password { Forgery::Basic.password :at_least => 6, :at_most => 16 }
    u.password_confirmation { |u2| u2.password }
    after(:create) { |u2| u2.confirm! }
  end

  factory :superuser, :parent => :user do |u|
    u.superuser true
  end

  # factory :author, :parent => :user do |a|
  # end
end
