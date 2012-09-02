# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe AdmissionsController do
  include ActionController::AuthenticationTestHelper

  render_views

  before(:each) do
    @space = Factory(:space)
    @admin = Factory(:admin_performance, :stage => @space).agent
    @user = Factory(:user_performance, :stage => @space).agent
    @invited = Factory(:invited_performance, :stage => @space).agent
  end

  describe "as Anonymous" do
    it "should not render index" do
      get :index, :space_id => @space.to_param
      assert_response 302
      response.should redirect_to(new_session_path)
    end

  end

  describe "as admin" do
    before do
      login_as(@admin)
    end

    it "should render index" do
      get :index, :space_id => @space.to_param
      assert_response 200
      response.should be_success
    end

    describe "with admissions" do
      before do
        FactoryGirl.create(:invitation, :group => @space)
        FactoryGirl.create(:candidate_invitation, :group => @space)
        FactoryGirl.create(:join_request, :group => @space)
      end

      it "should render index" do
        get :index, :space_id => @space.to_param
        assert_response 200
        response.should be_success
      end

    end
  end
end
