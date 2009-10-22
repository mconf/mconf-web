Factory.define :space do |s|
  s.sequence(:name) { |n| "Space #{ n }" }
  s.description "Space description"
  s.mailing_list "list@vcc-test.dit.upm.es"
end

Factory.define :public_space, :parent => :space do |s|
  s.public true
end

Factory.define :private_space, :parent => :space do |s|
  s.public false
end

def populated_space(s)
  2.times do
    Factory.create(:admin_performance, :stage => s)
  end
  5.times do
    Factory.create(:user_performance, :stage => s)
  end
  3.times do
    Factory.create(:invited_performance, :stage => s)
  end
  s.reload
end

def populated_public_space
  populated_space Factory(:public_space)
end

def populated_private_space
  populated_space = Factory(:private_space)
end
