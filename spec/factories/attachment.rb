# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :attachment do |a|
  end

  factory :attachment_with_associations, parent: :attachment do |a|
    a.association :space, :repository => true
    a.association :author, :factory => :user
  end
end
