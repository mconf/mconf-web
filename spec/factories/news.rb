FactoryGirl.define do
  factory :news do |p|
    p.sequence(:title) { |n| "News #{ n }" }
    p.sequence(:text) { |n| "Text #{ n }" }
    p.created_at { Time.now }
    p.updated_at { Time.now }
  end
end
