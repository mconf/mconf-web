Factory.define :private_message do |m|
  m.sequence(:title) { |n| "Message #{n}" }
  m.sequence(:body) { |n| "Message body #{n}" }
  m.checked { false }
  m.deleted_by_sender { false }
  m.deleted_by_receiver { false }
end
