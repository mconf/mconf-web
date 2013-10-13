# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

FactoryGirl.define do
  factory :space do |s|
    s.sequence(:name) { |n| Forgery::Name.unique_space_name(n) }
    s.description { Forgery::Basic.text }
    s.public false
    s.association :bigbluebutton_room
    s.deleted false
    s.repository false
    s.disabled false
  end

  factory :public_space, :parent => :space do |s|
    s.public true
  end

  factory :private_space, :parent => :space do |s|
    s.public false
  end
end
