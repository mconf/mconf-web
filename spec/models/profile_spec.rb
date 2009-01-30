require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Profile do
  before(:each) do
    @valid_attributes = {:name => "pepe", 
                             :lastname => "jugon",
                             :phone => "673548798",
                             :city => "Madrid",
                             :country => "Spain",
                             :organization => "Dit"}
    @invalid_attributes = {:name => "pepe"}
  end

  it "should create a new instance given valid attributes" do
    Profile.create!(@valid_attributes)
  end
  
  it "should NOT create a new instance given invalid attributes" do
    assert_no_difference 'Profile.count' do
      Profile.create(@invalid_attributes)
    end
  end
end
