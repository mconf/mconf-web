require "spec_helper"

describe SitesController do

  include ActionController::AuthenticationTestHelper

  render_views

  before(:each) do
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


