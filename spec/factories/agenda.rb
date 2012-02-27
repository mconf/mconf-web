FactoryGirl.define do
  factory :agenda do |a|
    a.association :event, :factory => :event
  end
end
