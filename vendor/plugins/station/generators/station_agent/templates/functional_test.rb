require File.dirname(__FILE__) + '/../test_helper'

class <%= controller_class_name %>ControllerTest < ActionController::TestCase
  # Be sure to include ActionController::AuthenticationTestHelper in test/test_helper.rb instead
  # Then, you can remove it from this and the units test.
  include ActionController::AuthenticationTestHelper

  fixtures :<%= table_name %>

  def setup
    @controller = <%= controller_class_name %>Controller.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_login_and_redirect
    post :create, :login => 'quentin', :password => 'test'
    assert session[:agent_id]
    assert session[:agent_type]
    assert_response :redirect
  end

  def test_should_fail_login_and_not_redirect
    post :create, :login => 'quentin', :password => 'bad password'
    assert_nil session[:agent_id]
    assert_nil session[:agent_type]
    assert_response :success
  end

  def test_should_logout
    login_as :quentin
    get :destroy
    assert_nil session[:agent_id]
    assert_nil session[:agent_type]
    assert_response :redirect
  end

  def test_should_remember_me
    post :create, :login => 'quentin', :password => 'test', :remember_me => "1"
    assert_not_nil @response.cookies["auth_token"]
  end

  def test_should_not_remember_me
    post :create, :login => 'quentin', :password => 'test', :remember_me => "0"
    assert_nil @response.cookies["auth_token"]
  end
  
  def test_should_delete_token_on_logout
    login_as :quentin
    get :destroy
    assert_equal @response.cookies["auth_token"], []
  end

  def test_should_login_with_cookie
    <%= table_name %>(:quentin).remember_me
    @request.cookies["auth_token"] = cookie_for(:quentin)
    get :new
    assert @controller.send(:authenticated?)
  end

  def test_should_fail_expired_cookie_login
    <%= table_name %>(:quentin).remember_me
    <%= table_name %>(:quentin).update_attribute :remember_token_expires_at, 5.minutes.ago
    @request.cookies["auth_token"] = cookie_for(:quentin)
    get :new
    assert !@controller.send(:authenticated?)
  end

  def test_should_fail_cookie_login
    <%= table_name %>(:quentin).remember_me
    @request.cookies["auth_token"] = auth_token('invalid_auth_token')
    get :new
    assert !@controller.send(:authenticated?)
  end

  protected
    def auth_token(token)
      CGI::Cookie.new('name' => 'auth_token', 'value' => token)
    end
    
    def cookie_for(<%= file_name %>)
      auth_token <%= table_name %>(<%= file_name %>).remember_token
    end
end
