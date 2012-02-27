FactoryGirl.define do
  factory :performance do |m|
    m.association :agent, :factory => :user
    m.association :stage, :factory => :space
  end

  factory :admin_performance, :parent => :performance do |m|
    m.role { |p| Space.role("Admin") }
  end

  factory :user_performance, :parent => :performance do |m|
    m.role { |p| Space.role("User") }
  end

  factory :invited_performance, :parent => :performance do |m|
    m.role { |p| Space.role("Invited") }
  end
end
