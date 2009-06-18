Factory.define :performance do |m|
  m.association :agent, :factory => :user
  m.association :stage, :factory => :space
end

Factory.define :admin_performance, :parent => :performance do |m|
  m.role { |p| Space.role("Admin") }
end

Factory.define :user_performance, :parent => :performance do |m|
  m.role { |p| Space.role("User") }
end

Factory.define :invited_performance, :parent => :performance do |m|
  m.role { |p| Space.role("Invited") }
end
