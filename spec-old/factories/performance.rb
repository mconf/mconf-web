# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

FactoryGirl.define do
  factory :performance do |m|
    m.association :agent, :factory => :user
    m.association :stage, :factory => :space
  end

  factory :admin_performance, :parent => :performance do |m|
    m.role { |p| Space.role("Admin") }
  end

  factory :user_performance, :parent => :performance do |m|
    m.role { |p| Space.role("User") }
  end

  factory :invited_performance, :parent => :performance do |m|
    m.role { |p| Space.role("Invited") }
  end
end
