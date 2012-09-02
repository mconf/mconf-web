# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

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


