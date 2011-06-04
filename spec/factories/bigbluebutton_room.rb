Factory.define :bigbluebutton_room do |r|
  r.sequence(:name) { |n| "Room #{n}" }
  r.association :server, :factory => :bigbluebutton_server
end
