FactoryGirl.define do
  factory:bigbluebutton_server do |s|
    s.sequence(:name) { |n| "Server #{n}" }
    s.sequence(:url) { |n| "http://server#{n}/bigbluebutton/api" }
    s.sequence(:salt) { |n| "1234567890abcdefghijkl#{n}" }
    s.version "0.7"
  end
end
