# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

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
    describe 'with valid login and password of user' do
      before do
        user_attributes = FactoryGirl.attributes_for(:user)
        @user = User.create(user_attributes)
        @user.activate
        @credentials = user_attributes.reject{ |k, v|
          ! [ :login, :password ].include?(k)
        }
      end

      it 'should validate user and redirect to home' do
        post :create, { :session => @credentials }

        assert controller.current_user == @user
        response.should redirect_to(home_path)
      end
    end

    describe 'with invalid login and password' do
      before do
        @credentials = { :login => 'bad', :password => 'incorrect' }
      end

      it 'should NOT validate user' do
        post :create, { :session => @credentials }

        controller.current_user.should be(nil)
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

