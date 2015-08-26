# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

FactoryGirl.define do
  factory :space do |s|
    s.permalink
    s.sequence(:name) { |n| Forgery::Name.unique_space_name(n) }
    s.description { Forgery::Basic.text }
    s.public false
    s.deleted false
    s.repository false
    s.disabled false
    s.approved true

    after(:build) { |space| space.stub(:create_webconf_room) }
    after(:build) { |space| space.stub(:update_webconf_room) }
  end

  factory :space_with_associations, parent: :space do
    after(:build) { |space| space.unstub(:create_webconf_room) }
    after(:build) { |space| space.unstub(:update_webconf_room) }
  end

  factory :public_space, parent: :space do |s|
    s.public true
  end

  factory :private_space, :parent => :space do |s|
    s.public false
  end
end
