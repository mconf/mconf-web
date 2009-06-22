Factory.define :space do |s|
  s.sequence(:name) { |n| "Space #{ n }" }
  s.description "Space description"

end

Factory.define :public_space, :parent => :space do |s|
  s.public true
end

Factory.define :private_space, :parent => :space do |s|
  s.public false
end

def populated_public_space
  s = Factory(:public_space)
  2.times do
    Factory.create(:admin_performance, :stage => s)
  end
  5.times do
    Factory.create(:user_performance, :stage => s)
  end
  s
end

def populated_private_space
  s = Factory(:private_space)
  2.times do
    Factory.create(:admin_performance, :stage => s)
  end
  5.times do
    Factory.create(:user_performance, :stage => s)
  end
  s
end
