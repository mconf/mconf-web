# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

FactoryGirl.define do
  factory :agenda_entry do |ae|
    ae.association :agenda, :factory => :agenda
    ae.start_time {Time.now + 2.hours + 15.minutes}
    ae.end_time {Time.now + 2.hours + 45.minutes}
    ae.sequence(:title) { |n| "AgendaEntry #{ n }" }
  end
end
