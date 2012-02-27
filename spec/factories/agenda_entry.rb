FactoryGirl.define do
  factory :agenda_entry do |ae|
    ae.association :agenda, :factory => :agenda
    ae.start_time {Time.now + 2.hours + 15.minutes}
    ae.end_time {Time.now + 2.hours + 45.minutes}
    ae.sequence(:title) { |n| "AgendaEntry #{ n }" }
  end
end
