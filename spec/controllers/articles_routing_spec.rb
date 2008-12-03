require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ArticlesController do
  
   before(:each) do
    @space = mock(Space, :id => '1', :name => "espacio") 
  end
  
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "articles", :action => "index", :space_id => @space.name).should == "/spaces/#{ @space.name }/articles"
    end
  
    it "should map #new" do
      route_for(:controller => "articles", :action => "new", :space_id => @space.name).should == "/spaces/#{ @space.name }/articles/new"
    end
  
    it "should map #show" do
      route_for(:controller => "articles", :action => "show", :id => 1, :space_id => @space.name).should == "/spaces/#{ @space.name }/articles/1"
    end
  
    it "should map #edit" do
      route_for(:controller => "articles", :action => "edit", :id => 1, :space_id => @space.name).should == "/spaces/#{ @space.name }/articles/1/edit"
    end
  
    it "should map #update" do
      route_for(:controller => "articles", :action => "update", :id => 1, :space_id => @space.name).should == "/spaces/#{ @space.name }/articles/1"
    end
  
    it "should map #destroy" do
      route_for(:controller => "articles", :action => "destroy", :id => 1, :space_id => @space.name).should == "/spaces/#{ @space.name }/articles/1"
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/spaces/#{ @space.name }/articles").should == {:controller => "articles", :action => "index", :space_id => @space.name}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/spaces/#{ @space.name }/articles/new").should == {:controller => "articles", :action => "new", :space_id => @space.name}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/spaces/#{ @space.name }/articles").should == {:controller => "articles", :action => "create", :space_id => @space.name}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/spaces/#{ @space.name }/articles/1").should == {:controller => "articles", :action => "show", :id => "1", :space_id => @space.name}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/spaces/#{ @space.name }/articles/1/edit").should == {:controller => "articles", :action => "edit", :id => "1", :space_id => @space.name}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/spaces/#{ @space.name }/articles/1").should == {:controller => "articles", :action => "update", :id => "1", :space_id => @space.name}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/spaces/#{ @space.name }/articles/1").should == {:controller => "articles", :action => "destroy", :id => "1", :space_id => @space.name}
    end
  end
end
