require File.dirname(__FILE__) + '/../spec_helper'

describe SessionsController do
  include ActionController::AuthenticationTestHelper

  render_views

  describe "new" do
    it 'should render' do
      get :new

      assert_response 200
    end
  end

  describe "create" do
    describe 'with valid login and password of user with chat' do
      before do
        user_attributes = Factory.attributes_for(:user)
        @user = User.create(user_attributes)
        @user.activate
        @credentials = user_attributes.reject{ |k, v|
          ! [ :login, :password ].include?(k)
        }
      end

      it 'should validate user and redirect to home with chat' do
        post :create, @credentials

        assert controller.current_user == @user
        response.should redirect_to(home_path)
      end
    end

    describe 'with valid login and password of user without chat' do
      before do
        user_attributes = Factory.attributes_for(:user_without_chat)
        @user = User.create(user_attributes)
        @user.activate
        @credentials = user_attributes.reject{ |k, v|
          ! [ :login, :password ].include?(k)
        }
      end

      it 'should validate user and redirect to home without chat' do
        post :create, @credentials

        assert controller.current_user == @user
        response.should redirect_to(home_path)
      end
    end

    describe 'with invalid login and password' do
      before do
        @credentials = { :login => 'bad', :password => 'incorrect' }
      end

      it 'should NOT validate user' do
        post :create, @credentials

        controller.current_user.should be(Anonymous.current)
        assert_response 200
        response.should render_template('new')
      end
    end

  end

  describe "on logout" do
    before do
      login_as Factory(:user)
    end

    it 'should destroy session' do
      get :destroy

      session[:agent_id].should be_nil
      session[:agent_type].should be_nil
      response.should be_redirect
    end
  end
end

