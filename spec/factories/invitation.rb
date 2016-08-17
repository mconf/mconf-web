# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

FactoryGirl.define do
  factory :invitation do |invitation|
    invitation.association :recipient, factory: :user
    invitation.association :sender, factory: :user
    invitation.type {  }
    invitation.title { Forgery::Name.first_name }
    invitation.description { Forgery::LoremIpsum.paragraph }
    invitation.url { 'http://' + Forgery::Internet.domain_name + '/' + Forgery::Internet.user_name }
    invitation.starts_on { Time.now }
    invitation.ends_on { Time.now + 2.hours }
    invitation.ready true
    invitation.sent true
    invitation.result true
  end

  factory :web_conference_invitation, parent: :invitation, class: WebConferenceInvitation do |invitation|
    invitation.association :target, factory: :bigbluebutton_room
    invitation.type "WebConferenceInvitation"
  end

  factory :event_invitation, parent: :invitation, class: EventInvitation do |invitation|
    invitation.association :target, factory: :event
    invitation.type "EventInvitation"
  end
end
