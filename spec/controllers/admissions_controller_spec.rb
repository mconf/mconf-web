require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

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
      assert_response 401
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
        Factory.create(:invitation, :group => @space)
        Factory.create(:candidate_invitation, :group => @space)
        Factory.create(:join_request, :group => @space)
      end

      it "should render index" do
        get :index, :space_id => @space.to_param
        assert_response 200
        response.should be_success
      end

    end
  end
end
