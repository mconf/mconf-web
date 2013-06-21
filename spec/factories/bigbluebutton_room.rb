Factory.define :bigbluebutton_room do |r|
  # meetingid with a random factor to avoid duplicated ids in consecutive test runs
  r.sequence(:meetingid) { |n| "meeting-#{n}-" + SecureRandom.hex(4) }
  r.association :server, :factory => :bigbluebutton_server
  r.sequence(:name) { |n| "Name#{n}" }
  r.sequence(:attendee_password) { |n| "pass-#{n}-" + SecureRandom.hex(2) }
  r.sequence(:moderator_password) { |n| "pass-#{n}-" + SecureRandom.hex(2) }
  r.sequence(:welcome_msg) { |n| "Welcome to #{n}" }
  r.private false
  r.sequence(:param) { |n| "meeting-#{n}" }
  r.external false
  r.record false
  r.duration 0
end
