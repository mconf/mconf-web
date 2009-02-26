require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Article do
  fixtures :users, :spaces

  before(:each) do
    @valid_attributes = {:title => 'title', 
                         :text  => 'text'
    }
    @author = users(:user_normal)
    @container = spaces(:private_admin)
  end

  it "should create a new instance given valid attributes" do
    a = Article.new(@valid_attributes)
    a.author = @author
    a.container = @container
    a.should be_valid
  end
  
  it "should not create a new instance given no title" do
    a = Article.new(:title => 'title')
    a.author = @author
    a.container = @container
    a.should_not be_valid
  end
  
  it "should not create a new instance given no description text" do
    a = Article.new(:text => 'text')
    a.author = @author
    a.container = @container
    a.should_not be_valid
  end
end
