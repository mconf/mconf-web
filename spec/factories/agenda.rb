Factory.define :agenda do |a|
  a.association :event, :factory => :event
end
