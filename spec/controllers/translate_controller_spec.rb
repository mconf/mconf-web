=begin
require "spec_helper"

describe TranslateController do

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
      get :index

      assert_response 200
    end
  end
end
=end
