# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

FactoryGirl.define do
  sequence(:email) { |n| Forgery::Internet.unique_email_address(n) }
  sequence(:username) { |n| Forgery::Internet.unique_user_name(n) }
  sequence(:permalink) { |n| Forgery::Internet.unique_permalink(n) }
  sequence(:timezone) { |n| Forgery::Time.zone }
end
