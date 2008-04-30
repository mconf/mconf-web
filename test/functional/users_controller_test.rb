require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < Test::Unit::TestCase
  include CMS::AuthenticationTestHelper

  fixtures :users

  def setup
    @controller = UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_allow_signup
    assert_difference 'User.count' do
      create_user
      assert_response :redirect
      assert  flash[:notice].include?("Thanks for signing up!")
    end
  end


  def test_should_require_login_on_signup
    assert_no_difference 'User.count' do
      create_user(:login => nil)
      assert assigns(:agent).errors.on(:login)
      assert_response :success
    end
  end


  def test_should_require_password_on_signup
    assert_no_difference 'User.count' do
      create_user(:password => nil)
      assert assigns(:agent).errors.on(:password)
      assert_response :success
    end
  end


  def test_should_require_password_confirmation_on_signup
    assert_no_difference 'User.count' do
      create_user(:password_confirmation => nil)
      assert assigns(:agent).errors.on(:password_confirmation)
      assert_response :success
    end
  end


  def test_should_require_email_on_signup
    assert_no_difference 'User.count' do
      create_user(:email => nil)
      assert assigns(:agent).errors.on(:email)
      assert_response :success
    end
  end
  

  def test_update_my_user
    login_as("user_normal")
    post :update, :id=>25, :tag=>{"add_tag"=>"bueno"}, :user => { :login => 'quire', :email => 'quire@example.com',
        :password => 'quire', :password_confirmation => 'quire' }
    assert_response :redirect  
    assert flash[:notice].include?("User was successfully updated.")
  end
  
  
  def test_update_another_user_not_being_admin
    login_as("user_normal")
    post :update, :id=>24,:tag=>{"add_tag"=>"bueno"}, :user => { :login => 'quire', :email => 'quire@example.com',
        :password => 'quire', :password_confirmation => 'quire' }
    assert_response :redirect  
    assert  flash[:notice].include?("User was successfully updated.")
  end

  def test_should_edit_user
    login_as("user_normal")
    get :edit, :id => users(:user_normal).id
    assert :success
  end
  

  protected
    def create_user(options = {})
      post :create, :tag=>{"add_tag"=>"bueno"}, :agent => { :login => 'quire', :email => 'quire@example.com',
        :password => 'quire', :password_confirmation => 'quire' }.merge(options)
    end
end
