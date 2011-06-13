require "spec_helper"

describe ProfilesController do
  describe "routing" do

    #it "do not recognizes #new" do # TODO this route is not necessary but station adds it
    #  { :get => '/profiles/new' }.should_not be_routable
    #end

    it "do not recognizes #new for users" do
      { :get => '/users/user-1/profile/new' }.should_not be_routable
    end

    it "do not recognizes #new for spaces/users" do
      { :get => '/spaces/space-1/users/user-1/profile/new' }.should_not be_routable
    end

    #it "do not recognizes #create" do # TODO this route is not necessary but station adds it
    #  { :post => '/profiles' }.should_not be_routable
    #end

    it "do not recognizes #create for users" do
      { :post => '/users/user-1/profile' }.should_not be_routable
    end

    it "do not recognizes #create for spaces/users" do
      { :post => '/spaces/space-1/users/user-1/profile' }.should_not be_routable
    end
  end
end
