require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  before(:each) do
    @valid_attributes = {:login => 'pepe',:password => '1234', :password_confirmation => '1234',:email => 'pepe@gmail.com'}
  end

  it "should create a new instance given valid attributes" do
    User.create(@valid_attributes).should be_valid
  end
  
  it "should not create a new instance given no title" do
    User.create(:email => nil).should_not be_valid
  end
  
end