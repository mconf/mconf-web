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
      user_attrs = Factory.attributes_for(:user)

      post :create, :space_id => @space.to_param,
        :user => user_attrs, :register => "true"

      response.should be_redirect
      assigns[:join_request].should be_valid
      assigns[:join_request].email.should == user_attrs[:email]

      assert authenticated?
      assert current_agent.email.should == assigns[:join_request].email
    end

  end

  describe "as other user" do
    before do
      @other_user = Factory.create(:user)

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

      assert authenticated?
      assert current_agent.email.should == assigns[:join_request].email

      ActionMailer::Base.deliveries.size.should == 1
    end
  end

  describe "as authenticated user" do
    before do
      @auth_user = Factory.create(:user)
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

      assert authenticated?
      assert current_agent.email.should == assigns[:join_request].email

      ActionMailer::Base.deliveries.size.should == 1
    end
  end


=begin
  describe "as admin" do

    before do
      login_as(@admin)

      ActionMailer::Base.delivery_method = :test
      ActionMailer::Base.perform_deliveries = true
      ActionMailer::Base.deliveries = []
    end

    describe "POST new" do
      it "creates new Invitation" do
        post :create, :group_id => @group.id,
                      :invitation => Factory.attributes_for(:invitation)
        response.should be_redirect
        assigns[:invitation].should be_valid
        assigns[:invitation].introducer.should == @admin
        ActionMailer::Base.deliveries.size.should == 1
        ActionMailer::Base.deliveries.first.body.should =~
          /#{ assigns[:invitation].comment }/
      end

    end

  end

  describe "accepting invitation" do
    describe "without candidate" do
      before do
        @invitation = Factory.create(:invitation, :candidate => nil)
      end

      it "should render" do
        get :show, :id => @invitation.code
        response.should be_success
      end

      describe "and registering" do

        it "creates and includes her in the group" do
          post :update, :id => @invitation.code,
                        :invitation => { :processed => true,
                                         :accepted => true },
                        :user => { :login => "Invited User",
                                   :password => "invitation_test",
                                   :password_confirmation => "invitation_test" }
          assigns[:invitation].should be_valid
          assigns[:invitation].state.should == :accepted

          assert authenticated?
          assert current_agent.email.should == @invitation.email

          assert @invitation.group.users.include? current_agent
        end

      end


    end

    describe "with candidate" do
      before do
        @invitation = Factory.create(:invitation, :email => nil)
      end

      it "should redirect the user to sessions/new" do
        get :show, :id => @invitation.code, :format => 'html'
        response.should redirect_to(new_session_url)
      end

      describe "authenticated" do
        before do
          login_as @invitation.candidate
        end

        it "should render" do
          get :show, :id => @invitation.code
          assigns[:invitation].should == @invitation
          response.should be_success
        end

        it "creates and includes her in the group" do
          post :update, :id => @invitation.code,
                        :invitation => { :processed => true,
                                         :accepted => true }
          assigns[:invitation].should be_valid
          assigns[:invitation].state.should == :accepted

          assert current_agent.email.should == @invitation.email

          assert @invitation.group.users.include? current_agent
        end

      end
    end
  end
=end

end
