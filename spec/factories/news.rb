# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

FactoryGirl.define do
  factory :news do |p|
    p.sequence(:title) { |n| Forgery::Basic.unique_text(n) }
    p.text { Forgery::Basic.text }
    p.created_at { Time.now }
    p.updated_at { Time.now }
    p.association :space, :factory => :space
  end
end
