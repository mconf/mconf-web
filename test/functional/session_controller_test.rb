require File.dirname(__FILE__) + '/../test_helper'


class SessionsControllerTest < ActionController::TestCase
  include ActionController::AuthenticationTestHelper
  
  fixtures :users
  
  def setup
    @controller = SessionsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  
  def test_should_login_and_redirect
    post :create, :login => 'quentin', :password => 'test'
    
    assert logged_in_session?
    assert_response :redirect
  end
  def test_should_login_with_openid
    post :create, :openid_identifier => 'http://cantorrodista.myopenid.com'
    
    
    assert_response :redirect
  end
  
  def test_should_fail_login_and_not_redirect
    post :create, :login => 'quentin', :password => 'bad password'
    assert ! logged_in_session?
    assert_response :success
  end
  
  
  def test_should_logout
    login_as :quentin
    get :destroy
    assert ! logged_in_session?
    assert_response :redirect
  end
  
  
  def test_should_remember_me
    post :create, :login => 'quentin', :password => 'test', :remember_me => "1"
    assert_not_nil @response.cookies["auth_token"]
  end
  
  
  def test_should_not_remember_me
    post :create, :login => 'quentin', :password => 'test', :remember_me => "0"
    assert @response.cookies["auth_token"].blank?
  end
  
  
  def test_should_delete_token_on_logout
    login_as :quentin
    get :destroy
    assert @response.cookies["auth_token"].blank?
  end
  
  
  def test_should_login_with_cookie
    users(:quentin).remember_me
    @request.cookies["auth_token"] = cookie_for(:quentin)
    get :new
    assert @controller.send(:logged_in?)
  end
  
  
  def test_should_fail_expired_cookie_login
    users(:quentin).remember_me
    users(:quentin).update_attribute :remember_token_expires_at, 5.minutes.ago
    @request.cookies["auth_token"] = cookie_for(:quentin)
    get :new
    assert !@controller.send(:logged_in?)
  end
  
  
  def test_should_fail_cookie_login
    users(:quentin).remember_me
    @request.cookies["auth_token"] = auth_token('invalid_auth_token')
    get :new
    assert !@controller.send(:logged_in?)
  end
  
  
  def test_login_with_no_validated_email
    post :create, :login => 'tarantino', :password => 'test'
    assert ! logged_in_session?
    assert_response :success
  end
  
  
  def test_login_with_disabled_user
    post :create, :login => 'deshabilitado', :password => 'admin'
    assert ! logged_in_session?
    assert_response :success
  end
  
  
  protected
  def auth_token(token)
    CGI::Cookie.new('name' => 'auth_token', 'value' => token)
  end
  
  def cookie_for(user)
    auth_token users(user).remember_token
  end
end
