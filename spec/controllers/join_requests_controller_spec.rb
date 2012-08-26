require "spec_helper"

describe JoinRequestsController do
  include ActionController::AuthenticationTestHelper

  render_views

  before(:each) do
    @space = Factory(:space)
    @admin = Factory(:admin_performance, :stage => @space).agent
    @user = Factory(:user_performance, :stage => @space).agent
    @invited = Factory(:invited_performance, :stage => @space).agent
  end

  describe "as Anonymous" do
    it "should render new form" do
      pending "define identification priority or alias before testing (see Bug #646)"
      get :new, :space_id => @space.to_param
      response.should be_success
    end

    it "should not create join request when sending invalid params" do
      pending "define identification priority or alias before testing (see Bug #646)"
      post :create, :space_id => @space.to_param,
        :user => {}
      response.should be_success
      response.should render_template "join_requests/new"
    end

    it "should register user when sending valid params" do
      user_attrs = FactoryGirl.attributes_for(:user)

      post :create, :space_id => @space.to_param,
        :user => user_attrs, :register => "true"

      response.should be_redirect
      assigns[:join_request].should be_valid
      assigns[:join_request].email.should == user_attrs[:email]

      assert user_signed_in?
      assert current_user.email.should == assigns[:join_request].email
    end

  end

  describe "as other user" do
    before do
      @other_user = FactoryGirl.create(:user)

      ActionMailer::Base.delivery_method = :test
      ActionMailer::Base.perform_deliveries = true
      ActionMailer::Base.deliveries = []
    end

    it "should authenticate user and send join request" do
      post :create, :space_id => @space.to_param,
        :user => { :email    => @other_user.email,
                   :password => @other_user.password }

      response.should be_redirect
      assigns[:join_request].should be_valid
      assigns[:join_request].candidate.should == @other_user

      assert user_signed_in?
      assert current_user.email.should == assigns[:join_request].email

      ActionMailer::Base.deliveries.size.should == 1
    end
  end

  describe "as authenticated user" do
    before do
      @auth_user = FactoryGirl.create(:user)
      login_as(@auth_user)

      ActionMailer::Base.delivery_method = :test
      ActionMailer::Base.perform_deliveries = true
      ActionMailer::Base.deliveries = []
    end

    it "should send join request" do
      post :create, :space_id => @space.to_param

      response.should be_redirect
      assigns[:join_request].should be_valid
      assigns[:join_request].candidate.should == @auth_user

      assert user_signed_in?
      assert current_user.email.should == assigns[:join_request].email

      ActionMailer::Base.deliveries.size.should == 1
    end
  end

end
