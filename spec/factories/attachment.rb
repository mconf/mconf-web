# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :attachment do |a|
    a.association :space
    a.association :author, :factory => :user
    a.uploaded_data { fixture_file_upload "#{PathHelpers.assets_full_path}/images/vcc-logo.png", "image/png" }
  end
end
