# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

FactoryGirl.define do
  factory :post do |p|
    p.sequence(:title) { |n| "Post #{ n }" }
    p.text "test"
    p.created_at { Time.now }
    p.updated_at { Time.now }
    #  p.reader_id
    #  p.space_id
    #  p.author_id
    #  p.author_type
    #  p.parent_id
    #  p.event_id
    #  p.guid
    #  p.spam
  end

  factory :post_empty_title, :parent => :post do |p|
    p.title "";
  end

  factory :post_empty_text, :parent => :post do |p|
    p.text "";
  end

  factory :post_spam, :parent => :post do |p|
    p.spam true;
  end

  #factory :superuser, :parent => :user do |u|
  #  p.superuser true
  #end
end
