require "spec_helper"

describe ProfilesController do
  describe "routing" do

    it "do not recognizes #new" do
      { :get => '/profiles/new' }.should_not be_routable
    end

    it "do not recognizes #new for users" do
      { :get => '/users/user-1/profile/new' }.should_not be_routable
    end

    it "do not recognizes #new for spaces/users" do
      { :get => '/spaces/space-1/users/user-1/profile/new' }.should_not be_routable
    end

    it "do not recognizes #create" do
      { :post => '/profiles' }.should_not be_routable
    end

    it "do not recognizes #create for users" do
      { :post => '/users/user-1/profile' }.should_not be_routable
    end

    it "do not recognizes #create for spaces/users" do
      { :post => '/spaces/space-1/users/user-1/profile' }.should_not be_routable
    end

=begin
    it "recognizes and generates #new" do
      { :get => "/address/new" }.should route_to(:controller => "addresses", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/address" }.should route_to(:controller => "addresses", :action => "show")
    end

    it "recognizes and generates #edit" do
      { :get => "/address/edit" }.should route_to(:controller => "addresses", :action => "edit")
    end

    it "recognizes and generates #create" do
      { :post => "/address" }.should route_to(:controller => "addresses", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/address" }.should route_to(:controller => "addresses", :action => "update")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/address" }.should route_to(:controller => "addresses", :action => "destroy")
    end
=end

  end
end
