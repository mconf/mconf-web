require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Machine do
  before(:each) do
    @valid_attributes = {:name => 'name', :nickname => 'nickname'
    }
  end

  it "should create a new instance given valid attributes" do
    Machine.create(@valid_attributes).should be_valid
  end
  
  it "should not create a new instance given no nickname" do
    Machine.create(:name => 'name').should_not be_valid
  end
  
  it "should not create a new instance given no name" do
    Machine.create(:nickname => 'nickname').should_not be_valid
  end
end
