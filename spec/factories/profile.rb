FactoryGirl.define do
  factory :profile do |p|
    p.association :user, :factory => :user
    p.organization "dit"
    p.city "madrid"
    p.country "spain"
    p.prefix_key "Mr."
    p.description "This is my description."
    p.url "http://website.example.com"
    p.skype "myskypename"
    p.im "im@example.com"
    p.visibility Profile::VISIBILITY.index(:public_fellows)
  end

  factory :vcard, :parent=>:profile do |v|
    v.phone     "656765654"
    v.mobile    "654654654"
    v.fax       "915443232"
    v.address   "C/ Monaco n.1 5.Izq"
    v.province  "Madrid"
    v.zipcode   "28029"
  end
end

