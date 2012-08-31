# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

FactoryGirl.define do
  factory :space do |s|
    s.sequence(:name) { |n| "Space #{ n }" }
    s.description "Space description"
    #TODO: this was possibly causing the error "Too many open files" in rake spec
    # s.default_logo "/models/front/space.png"
    s.public true
    s.association :bigbluebutton_room
  end

  factory :public_space, :parent => :space do |s|
    s.public true
  end

  factory :private_space, :parent => :space do |s|
    s.public false
  end

  factory :private_space_with_repository, :parent => :space do |s|
    s.public false
    s.repository true
  end

  factory :public_space_with_repository, :parent => :space do |s|
    s.public true
    s.repository true
  end
end

def populated_space(s)
  2.times do
    FactoryGirl.create(:admin_performance, :stage => s)
  end
  5.times do
    FactoryGirl.create(:user_performance, :stage => s)
  end
  3.times do
    FactoryGirl.create(:invited_performance, :stage => s)
  end
  s.reload
end

def populated_public_space
  populated_space(Factory(:public_space))
end

def populated_private_space
  populated_space(Factory(:private_space))
end
