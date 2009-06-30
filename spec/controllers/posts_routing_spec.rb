require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PostsController do
  
=begin
   before(:each) do
    @space = mock(Space, :id => '1', :name => "espacio") 
  end
  
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "posts", :action => "index", :space_id => @space.name).should == "/spaces/#{ @space.name }/posts"
    end
  
    it "should map #new" do
      route_for(:controller => "posts", :action => "new", :space_id => @space.name).should == "/spaces/#{ @space.name }/posts/new"
    end
  
    it "should map #show" do
      route_for(:controller => "posts", :action => "show", :id => 1, :space_id => @space.name).should == "/spaces/#{ @space.name }/posts/1"
    end
  
    it "should map #edit" do
      route_for(:controller => "posts", :action => "edit", :id => 1, :space_id => @space.name).should == "/spaces/#{ @space.name }/posts/1/edit"
    end
  
    it "should map #update" do
      route_for(:controller => "posts", :action => "update", :id => 1, :space_id => @space.name).should == "/spaces/#{ @space.name }/posts/1"
    end
  
    it "should map #destroy" do
      route_for(:controller => "posts", :action => "destroy", :id => 1, :space_id => @space.name).should == "/spaces/#{ @space.name }/posts/1"
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/spaces/#{ @space.name }/posts").should == {:controller => "posts", :action => "index", :space_id => @space.name}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/spaces/#{ @space.name }/posts/new").should == {:controller => "posts", :action => "new", :space_id => @space.name}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/spaces/#{ @space.name }/posts").should == {:controller => "posts", :action => "create", :space_id => @space.name}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/spaces/#{ @space.name }/posts/1").should == {:controller => "posts", :action => "show", :id => "1", :space_id => @space.name}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/spaces/#{ @space.name }/posts/1/edit").should == {:controller => "posts", :action => "edit", :id => "1", :space_id => @space.name}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/spaces/#{ @space.name }/posts/1").should == {:controller => "posts", :action => "update", :id => "1", :space_id => @space.name}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/spaces/#{ @space.name }/posts/1").should == {:controller => "posts", :action => "destroy", :id => "1", :space_id => @space.name}
    end
  end
=end
end
