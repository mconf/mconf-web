Factory.define :invitation do |m|
  m.sequence(:email) { |n| "invitation#{ n }@example.com" }
  m.association :group, :factory => :space
  m.association :introducer, :factory => :user
  m.comment "join!"
end

Factory.define :candidate_invitation, :parent => :invitation do |m|
  m.association :candidate, :factory => :user
  m.email { |a| a.candidate.email }
end

Factory.define :join_request do |m|
  m.association :candidate, :factory => :user
  m.email { |a| a.candidate.email }
  m.association :group, :factory => :space
  m.comment "approve me!"
end

