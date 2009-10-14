Factory.define :user do |u|
  u.sequence(:login) { |n| "User #{ n }" }
  u.sequence(:email) { |n| "user#{ n }@example.com" }
  u.password "test"
  u.password_confirmation "test"
  u.created_at { Time.now }
  u.updated_at { Time.now }
  u.activated_at { Time.now }
  u.disabled false
  u.activation_code "44rfrfr"
end

Factory.define :author, :parent => :user do |a|
end

Factory.define :superuser, :parent => :user do |u|
  u.superuser true
end
