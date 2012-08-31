# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

FactoryGirl.define do
  factory :event do |e|
    e.sequence(:name) { |n| "Event #{ n }" }
    e.sequence(:description)  { |n| "Event description #{ n }" }
    e.sequence(:place) { |n| "Place #{ n }" }
    e.start_date { Time.now + 2.hours}
    e.end_date { Time.now + 4.hours}
    #  e.machine_id
    #  e.colour",       :default => ""
    #  e.repeat"
    #  e.at_job"
    #  e.parent_id"
    #  e.character"
    #  e.public_read"
    #  e.created_at"
    #  e.updated_at"
    #  e.space_id"
    #  e.author_id"
    #  e.author_type"
    #  e.spam",         :default => false
    #  e.notes"
    e.vc_mode {0}
  end

  factory :event_public, :parent => :event do |e|
    e.public_read true
    e.association :space, :factory => :public_space
    # The author should be in the space
    e.author { |e| Factory(:admin_performance, :stage => e.space).agent }
  end

  factory :event_private, :parent => :event do |e|
    e.public_read false
    e.association :space, :factory => :private_space
    e.author { |e| Factory(:admin_performance, :stage => e.space).agent }
  end

  factory :event_spam, :parent => :event do |e|
    e.spam true
  end
end
