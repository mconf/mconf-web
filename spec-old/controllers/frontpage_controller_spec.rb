# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe FrontpageController do
  include ActionController::AuthenticationTestHelper

  render_views

  describe "when Anonymous" do
    it "should render show" do
      get :show
      assert_response :success
    end
  end

  describe "when authenticated" do
    before do
      login_as Factory(:user)
    end

    it "should redirect to home" do
      get :show
      response.should redirect_to(home_path)
    end
  end
end

