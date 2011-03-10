require "spec_helper"

describe SpacesController do
=begin
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "spaces", :action => "index").should == "/spaces"
    end
  
    it "should map #new" do
      route_for(:controller => "spaces", :action => "new").should == "/spaces/new"
    end
  
    it "should map #show" do
      route_for(:controller => "spaces", :action => "show", :id => 1).should == "/spaces/1"
    end
  
    it "should map #edit" do
      route_for(:controller => "spaces", :action => "edit", :id => 1).should == "/spaces/1/edit"
    end
  
    it "should map #update" do
      route_for(:controller => "spaces", :action => "update", :id => 1).should == "/spaces/1"
    end
  
    it "should map #destroy" do
      route_for(:controller => "spaces", :action => "destroy", :id => 1).should == "/spaces/1"
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/spaces").should == {:controller => "spaces", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/spaces/new").should == {:controller => "spaces", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/spaces").should == {:controller => "spaces", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/spaces/1").should == {:controller => "spaces", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/spaces/1/edit").should == {:controller => "spaces", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/spaces/1").should == {:controller => "spaces", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/spaces/1").should == {:controller => "spaces", :action => "destroy", :id => "1"}
    end
  end
=end
end
