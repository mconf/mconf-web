require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Article do
  fixtures :users, :spaces

  before(:each) do
    @valid_attributes = {:title => 'title', 
                         :text => 'text',  
                         :author => users(:user_normal), 
                         :container => spaces(:private_admin)
    }
  end

  it "should create a new instance given valid attributes" do
    Article.create(@valid_attributes).should be_valid
  end
  
  it "should not create a new instance given no title" do
    Article.create(:title => 'title').should_not be_valid
  end
  
  it "should not create a new instance given no description text" do
    Article.create(:text => 'text').should_not be_valid
  end
end
