Factory.define :user do |u|
  u.sequence(:login) { |n| "user-#{ n }" }
  u.sequence(:email) { |n| "user#{ n }@example.com" }
  u.password "test"
  u.password_confirmation "test"
  u.created_at { Time.now }
  u.updated_at { Time.now }
  u.activated_at { Time.now }
  u.disabled false
  u.chat_activation true
end

Factory.define :author, :parent => :user do |a|
end

Factory.define :superuser, :parent => :user do |u|
  u.superuser true
end

Factory.define :new_user, :parent => :user do |u|
  u.sequence(:_full_name) { |n| "User #{ n }" }
end

Factory.define :user_without_chat, :parent => :user do |u|
  u.chat_activation false
end