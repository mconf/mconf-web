require File.dirname(__FILE__) + '/../test_helper'

# Los tests comentados necesitan ser revisados

class UsersControllerTest < Test::Unit::TestCase
  include ActionController::AuthenticationTestHelper

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
    end
  end


#  def test_should_require_login_on_signup
#    assert_no_difference 'User.count' do
#      create_user(:user =>{:login => nil})
#      assert assigns(:agent).errors.on(:login)
#      assert_response :success
#    end
#  end
#
#
#  def test_should_require_password_on_signup
#    assert_no_difference 'User.count' do
#      create_user(:user =>{:password => nil})
#      assert assigns(:agent).errors.on(:password)
#      assert_response :success
#    end
#  end
#
#
#  def test_should_require_password_confirmation_on_signup
#    assert_no_difference 'User.count' do
#      create_user(:password_confirmation => nil)
#      assert assigns(:agent).errors.on(:password_confirmation)
#      assert_response :success
#    end
#  end
#
#
#  def test_should_require_email_on_signup
#    assert_no_difference 'User.count' do
#      create_user(:email => nil)
#      assert assigns(:agent).errors.on(:email)
#      assert_response :success
#    end
#  end
#  

  def test_update_my_user
    login_as("user_normal")
    post :update, :id=>25, :container_id => 1, :container_type => :spaces, :tags=>"bueno", :user => { :login => 'quire', :email => 'quire@example.com',
        :password => 'quire', :password_confirmation => 'quire' }
    assert_response :redirect  
    assert flash[:notice].include?("User was successfully updated.")
  end
  
  
#  def test_update_another_user_not_being_admin
#    login_as("user_normal")
#    post :update, :id=>24, :container_id => 1, :container_type => :spaces ,:tags=>"bueno", :user => { :login => 'quire', :email => 'quire@example.com',
#        :password => 'quire', :password_confirmation => 'quire' }
#    
#  end

  def test_should_edit_user
    login_as("user_normal")
    get :edit, :container_id => 1, :container_type => :spaces, :id => users(:user_normal).id
    assert :success
  end
  
#  def test_manage_users
#    login_as("user_admin")
#    get :manage_users, :container_id => 1, :container_type => :spaces
#    assert :success
#    assert_template 'manage_users'
#  end
#  
#  def test_manage_users_no_admin
#     login_as("user_normal")
#     get :manage_users, :container_id => 1, :container_type => :spaces
#     assert_redirected_to "/"
#     assert  flash[:notice].include?("Action not allowed")
#   end
#   
#   def test_manage_users_no_login
#     
#     get :manage_users, :container_id => 1, :container_type => :spaces
#     assert_redirected_to :controller=>'sessions', :action=>'new'
#
#end
#  
#   


 
 
  protected
    def create_user(options = {})
      post :create, :container_id => 1, :container_type => :spaces, :tags=>"bueno", :user => { :login => 'quire', :email => 'quire@example.com',
        :password => 'quire', :password_confirmation => 'quire' }.merge(options)
    end
end
