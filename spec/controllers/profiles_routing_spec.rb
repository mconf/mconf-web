require "spec_helper"

describe ProfilesController do
=begin
  before(:each)do
    @space = mock(Space, :id => '1', :name => "espacio")
  end
  describe "route generation" do
    
    #no hay ruta asociada a index
  
    it "should map #new" do
      route_for(:controller => "profiles", :action => "new", :user_id => 1).should == "/users/1/profile/new"
    end
  
    it "should map #show" do
      route_for(:controller => "profiles", :action => "show", :user_id => 1 ).should == "/users/1/profile"
    end
  
    it "should map #edit" do
      route_for(:controller => "profiles", :action => "edit", :user_id => 1).should == "/users/1/profile/edit"
    end
  
    it "should map #update" do
      route_for(:controller => "profiles", :action => "update", :user_id => 1).should == "/users/1/profile"
    end
  
    it "should map #destroy" do
      route_for(:controller => "profiles", :action => "destroy", :user_id => 1).should == "/users/1/profile"
    end
  end

  describe "route recognition" do
  
    it "should generate params for #new" do
      params_from(:get, "/users/1/profile/new").should == {:controller => "profiles", :action => "new", :user_id => "1"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/users/1/profile").should == {:controller => "profiles", :action => "create", :user_id => "1"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/users/1/profile").should == {:controller => "profiles", :action => "show", :user_id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/users/1/profile/edit").should == {:controller => "profiles", :action => "edit", :user_id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/users/1/profile").should == {:controller => "profiles", :action => "update", :user_id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/users/1/profile").should == {:controller => "profiles", :action => "destroy", :user_id => "1"}
    end
  end
=end
end
