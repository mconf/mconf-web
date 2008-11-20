require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MachinesController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "machines", :action => "index").should == "/machines"
    end
  
    it "should map #new" do
      route_for(:controller => "machines", :action => "new").should == "/machines/new"
    end
  
    it "should map #show" do
      route_for(:controller => "machines", :action => "show", :id => 1).should == "/machines/1"
    end
  
    it "should map #edit" do
      route_for(:controller => "machines", :action => "edit", :id => 1).should == "/machines/1/edit"
    end
  
    it "should map #update" do
      route_for(:controller => "machines", :action => "update", :id => 1).should == "/machines/1"
    end
  
    it "should map #destroy" do
      route_for(:controller => "machines", :action => "destroy", :id => 1).should == "/machines/1"
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/machines").should == {:controller => "machines", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/machines/new").should == {:controller => "machines", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/machines").should == {:controller => "machines", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/machines/1").should == {:controller => "machines", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/machines/1/edit").should == {:controller => "machines", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/machines/1").should == {:controller => "machines", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/machines/1").should == {:controller => "machines", :action => "destroy", :id => "1"}
    end
  end
end
