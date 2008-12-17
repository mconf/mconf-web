require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ProfilesController do
  before(:each)do
    @space = mock(Space, :id => '1', :name => "espacio")
  end
  describe "route generation" do
    
    #no hay ruta asociada a index
  
    it "should map #new" do
      route_for(:controller => "profiles", :action => "new", :space_id => @space.name, :user_id => 1).should == "/spaces/#{@space.name}/users/1/profile/new"
    end
  
    it "should map #show" do
      route_for(:controller => "profiles", :action => "show", :user_id => 1 , :space_id => @space.name).should == "/spaces/#{@space.name}/users/1/profile"
    end
  
    it "should map #edit" do
      route_for(:controller => "profiles", :action => "edit", :user_id => 1, :space_id => @space.name).should == "/spaces/#{@space.name}/users/1/profile/edit"
    end
  
    it "should map #update" do
      route_for(:controller => "profiles", :action => "update", :user_id => 1, :space_id => @space.name).should == "/spaces/#{@space.name}/users/1/profile"
    end
  
    it "should map #destroy" do
      route_for(:controller => "profiles", :action => "destroy", :user_id => 1, :space_id => @space.name).should == "/spaces/#{@space.name}/users/1/profile"
    end
  end

  describe "route recognition" do
  
    it "should generate params for #new" do
      params_from(:get, "/spaces/#{@space.name}/users/1/profile/new").should == {:controller => "profiles", :action => "new", :space_id => @space.name, :user_id => "1"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/spaces/#{@space.name}/users/1/profile").should == {:controller => "profiles", :action => "create", :space_id => @space.name, :user_id => "1"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/spaces/#{@space.name}/users/1/profile").should == {:controller => "profiles", :action => "show", :space_id => @space.name, :user_id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/spaces/#{@space.name}/users/1/profile/edit").should == {:controller => "profiles", :action => "edit", :space_id => @space.name, :user_id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/spaces/#{@space.name}/users/1/profile").should == {:controller => "profiles", :action => "update", :space_id => @space.name, :user_id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/spaces/#{@space.name}/users/1/profile").should == {:controller => "profiles", :action => "destroy", :space_id => @space.name, :user_id => "1"}
    end
  end
end
