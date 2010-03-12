require File.dirname(__FILE__) + '/../test_helper'

class <%= model_controller_class_name %>ControllerTest < ActionController::TestCase
  # Be sure to include ActionController::AuthenticationTestHelper in test/test_helper.rb instead
  # Then, you can remove it from this and the units test.
  include ActionController::AuthenticationTestHelper

  fixtures :<%= table_name %>

  def setup
    @controller = <%= model_controller_class_name %>Controller.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_allow_signup
    assert_difference '<%= class_name %>.count' do
      create_<%= file_name %>
      assert_response :redirect
    end
  end

  def test_should_require_login_on_signup
    assert_no_difference '<%= class_name %>.count' do
      create_<%= file_name %>(:login => nil)
      assert assigns(:agent).errors.on(:login)
      assert_response :success
    end
  end

  def test_should_require_password_on_signup
    assert_no_difference '<%= class_name %>.count' do
      create_<%= file_name %>(:password => nil)
      assert assigns(:agent).errors.on(:password)
      assert_response :success
    end
  end

  def test_should_require_password_confirmation_on_signup
    assert_no_difference '<%= class_name %>.count' do
      create_<%= file_name %>(:password_confirmation => nil)
      assert assigns(:agent).errors.on(:password_confirmation)
      assert_response :success
    end
  end

  def test_should_require_email_on_signup
    assert_no_difference '<%= class_name %>.count' do
      create_<%= file_name %>(:email => nil)
      assert assigns(:agent).errors.on(:email)
      assert_response :success
    end
  end

  <% if options[:include_activation] %>
  def test_should_activate_user
    assert_nil <%= class_name %>.authenticate_with_login_and_password('aaron', 'test')
    get :activate, :activation_code => <%= table_name %>(:aaron).activation_code
    assert_redirected_to '/'
    assert_not_nil flash[:notice]
    assert_equal <%= table_name %>(:aaron), <%= class_name %>.authenticate_with_login_and_password('aaron', 'test')
  end
  
  def test_should_not_activate_user_without_key
    get :activate
    assert_nil flash[:notice]
  rescue ActionController::RoutingError
    # in the event your routes deny this, we'll just bow out gracefully.
  end

  def test_should_not_activate_user_with_blank_key
    get :activate, :activation_code => ''
    assert_nil flash[:notice]
  rescue ActionController::RoutingError
    # well played, sir
  end
  <% end %>

  protected
    def create_<%= file_name %>(options = {})
      post :create, :agent => { :login => 'quire', :email => 'quire@example.com',
        :password => 'quire', :password_confirmation => 'quire' }.merge(options)
    end
end
