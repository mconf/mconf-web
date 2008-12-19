require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Space do
  before(:each) do
    @valid_attributes = {:name => 'title', :description => 'text'
    }
  end

  it "should create a new instance given valid attributes" do
    Space.create(@valid_attributes).should be_valid
  end
  
  it "should not create a new instance given no name" do
    Space.create(:name => 'title').should_not be_valid
  end
  
  it "should not create a new instance given no description" do
    Space.create(:description => 'text').should_not be_valid
  end
  
  it "should not create tow instances with the same name" do
    assert_difference 'Space.count', +1 do
    Space.create(@valid_attributes)
    Space.create(@valid_attributes)
    end
    assert_raise ActiveRecord::RecordInvalid do
    Space.create!(@valid_attributes).should be_false
    end
  end
end
