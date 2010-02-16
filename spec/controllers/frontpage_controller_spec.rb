require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FrontpageController do
  include ActionController::AuthenticationTestHelper
  
  integrate_views

  describe "when Anonymous" do
    it "should render index" do
      get :index
      assert_response :success
    end
  end

  describe "when authenticated" do
    before do
      login_as Factory(:user)
    end

    it "should render index" do
      get :index
      assert_response :success
    end
  end
end
  
