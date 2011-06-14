require "spec_helper"

describe Post do

  before(:each) do
    @valid_attributes = {:title => 'title',
                         :text  => 'text'
    }
  end

  it "should create a new instance given valid attributes" do
    a = Post.new(@valid_attributes)
    a.author = Factory(:user)
    a.container = Factory(:space)
    a.should be_valid
  end

  it "should not create a new instance given no title" do
    a = Post.new(:text => 'text')
    a.author = Factory(:user)
    a.container = Factory(:space)
    a.should_not be_valid
  end

  it "should not create a new instance given no description text" do
    a = Post.new(:text => 'text')
    a.author = Factory(:user)
    a.container = Factory(:space)
    a.should_not be_valid
  end

  it "should not duplicate post attachments in nested attributes" do
    attributes = Factory.attributes_for(:post)
    attributes['attachments_attributes'] = { '1' => Factory.attributes_for(:attachment) }

    post = Post.create!(attributes)
    assert_equal 1, post.reload.attachments.count
  end

end
