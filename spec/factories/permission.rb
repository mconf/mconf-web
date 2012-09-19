# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

FactoryGirl.define do
  factory :permission do |m|
    m.association :user
  end

  factory :event_permission, :parent => :permission do |m|
    m.association :subject, :factory => :event
    m.role { Role.find_by_name_and_stage_type('Participant', 'Event') }
  end

  factory :space_permission, :parent => :permission do |m|
    m.association :subject, :factory => :space
    m.role { Role.find_all_by_stage_type('Space').first }
  end
end
