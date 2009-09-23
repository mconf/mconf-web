Factory.define :event do |e|
  e.sequence(:name) { |n| "Event #{ n }" }
  e.description "Event description"
  e.sequence(:place) { |n| "Place #{ n }" }
  #  e.isabel_event
  e.start_date { Time.now }
  e.end_date { Time.now }
  #  e.machine_id 
  #  e.colour",       :default => ""
  #  e.repeat"
  #  e.at_job"
  #  e.parent_id"
  #  e.character"
  #  e.public_read"
  #  e.created_at"
  #  e.updated_at"
  #  e.space_id"
  #  e.author_id"
  #  e.author_type"
  #  e.marte_event",  :default => false
  #  e.marte_room"
  #  e.spam",         :default => false
  #  e.notes"
end

Factory.define :event_public, :parent => :event do |e|
  e.public_read true
end

Factory.define :event_private, :parent => :event do |e|
  e.public_read false
end

Factory.define :event_spam, :parent => :event do |e|
  e.spam true
end
