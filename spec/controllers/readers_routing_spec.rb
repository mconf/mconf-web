require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ReadersController do
  
  before(:each) do
    @space = mock(Space, :id => '1', :name => "espacio")
  end
  
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "readers", :action => "index", :space_id => @space.name).should == "/spaces/#{ @space.name }/readers"
    end
  
    it "should map #new" do
      route_for(:controller => "readers", :action => "new", :space_id => @space.name).should == "/spaces/#{ @space.name }/readers/new"
    end
  
    it "should map #show" do
      route_for(:controller => "readers", :action => "show", :id => 1, :space_id => @space.name).should == "/spaces/#{ @space.name }/readers/1"
    end
  
    it "should map #edit" do
      route_for(:controller => "readers", :action => "edit", :id => 1, :space_id => @space.name).should == "/spaces/#{ @space.name }/readers/1/edit"
    end
  
    it "should map #update" do
      route_for(:controller => "readers", :action => "update", :id => 1, :space_id => @space.name).should == "/spaces/#{ @space.name }/readers/1"
    end
  
    it "should map #destroy" do
      route_for(:controller => "readers", :action => "destroy", :id => 1, :space_id => @space.name).should == "/spaces/#{ @space.name }/readers/1"
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/spaces/#{ @space.name }/readers").should == {:controller => "readers", :action => "index", :space_id => @space.name}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/spaces/#{ @space.name }/readers/new").should == {:controller => "readers", :action => "new", :space_id => @space.name}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/spaces/#{ @space.name }/readers").should == {:controller => "readers", :action => "create", :space_id => @space.name}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/spaces/#{ @space.name }/readers/1").should == {:controller => "readers", :action => "show", :id => "1", :space_id => @space.name}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/spaces/#{ @space.name }/readers/1/edit").should == {:controller => "readers", :action => "edit", :id => "1", :space_id => @space.name}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/spaces/#{ @space.name }/readers/1").should == {:controller => "readers", :action => "update", :id => "1", :space_id => @space.name}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/spaces/#{ @space.name }/readers/1").should == {:controller => "readers", :action => "destroy", :id => "1", :space_id => @space.name}
    end
  end
end
