# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

FactoryGirl.define do
  factory :user do |u|
    u.sequence(:login) { |n| "user-#{ n }" }
    u.sequence(:email) { |n| "user#{ n }@example.com" }
    u.password "test"
    u.password_confirmation "test"
    u.created_at { Time.now }
    u.updated_at { Time.now }
    u.activated_at { Time.now }
    u.disabled false
    u.sequence(:_full_name) { |n| "User #{ n }" }
    u.receive_digest { User::RECEIVE_DIGEST_NEVER }
  end

  factory :author, :parent => :user do |a|
  end

  factory :superuser, :parent => :user do |u|
    u.superuser true
  end
end
