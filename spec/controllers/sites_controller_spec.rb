require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SitesController do
  
  include ActionController::AuthenticationTestHelper
  
  integrate_views
  
  before(:all) do
    @superuser = Factory(:superuser)
  end

  describe "a Superadmin" do
    before(:each) do
      login_as(@superuser)
    end

    it "should show site" do
      get :show

      assert_response 200
    end

    it "should edit site" do
      get :edit

      assert_response 200
    end

  end

end


