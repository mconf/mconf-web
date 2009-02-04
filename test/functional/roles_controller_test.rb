require File.dirname(__FILE__) + '/../test_helper'

class RolesControllerTest < ActionController::TestCase
 
  include ActionController::AuthenticationTestHelper
  fixtures :users, :cms_performances, :cms_roles, :spaces
  
#  def test_index_admin
#     login_as("user_admin")
#     get :index, :container_type=>'space', :container_id=>'1'
#     assert_response :success
#     assert_template "index"
#  end
#
#
#  def test_show_roles_admin
#    login_as("user_admin")
#     get :show, :id=>1, :container_type=>'space', :container_id=>'1'
#     assert_response :success
#     assert_template "show"
#  end
#  
#
#  def test_should_not_allow_index_not_admin
#     login_as("user_normal")
#     get :index, :container_type=>'space', :container_id=>'1'
#     assert_redirected_to "/"
#  end
#
#
#  def test_should_not_allow_show_roles_not_admin
#    login_as("user_normal")
#     get :show, :id=>1, :container_type=>'space', :container_id=>'1'
#     assert_redirected_to "/"
#  end
# 
# 
#  def test_new_admin
#   login_as("user_admin")
#    get :new, :container_type=>'space', :container_id=>'1'
#    assert_template "new" 
#    assert_response :success
#  end
#  
#  
#  def test_should_not_allow_new_roles_not_admin
#    login_as("user_normal")
#     get :new, :container_type=>'space', :container_id=>'1'
#     assert_redirected_to "/"
#  end
#  
#  
#  def test_edit_admin
#    login_as("user_admin")
#    post :edit, :id=>1, :container_type=>'space', :container_id=>'1'
#    assert_template "edit" 
#    assert_response :success
#  end
#  
#  
#  def test_should_not_allow_edit_roles_not_admin
#    login_as("user_normal")
#     get :edit, :id=>1, :container_type=>'space', :container_id=>'1'
#     assert_redirected_to "/"
#  end
#  
#  
#  def test_create_admin
#    login_as("user_admin")
#    post :create, :name=> "administer", :container_type=>'space', :container_id=>'1', :create_posts=> true, :read_posts=> true, :update_posts=> true, :delete_posts=> true, :create_performances=> true, :read_performances=> true, :update_performances=> true, :delete_performances=> true, :manage_events=> true, :admin=> true, :type=> ""
#    assert_response :success    
#  end
#  
#  
#  def test_update_admin
#    login_as("user_admin")
#    post :update, :id=>"1", :container_type=>'space', :container_id=>'1', :name=> "administer", :create_posts=> true, :read_posts=> true, :update_posts=> true, :delete_posts=> true, :create_performances=> true, :read_performances=> true, :update_performances=> true, :delete_performances=> true, :manage_events=> true, :admin=> true, :type=> ""
#    assert_redirected_to :controller => "roles", :action => "index"  
#  end
#  
#  
#  def test_create_not_admin
#    login_as("user_normal")
#    post :create, :container_type=>'space', :container_id=>'1', :name=> "administer", :create_posts=> true, :read_posts=> true, :update_posts=> true, :delete_posts=> true, :create_performances=> true, :read_performances=> true, :update_performances=> true, :delete_performances=> true, :manage_events=> true, :admin=> true, :type=> ""
#    assert_redirected_to "/"
#  end
#  
#  
#  def test_update_not_admin
#    login_as("user_normal")
#    post :update, :container_type=>'space', :container_id=>'1', :id=>"1", :name=> "administer", :create_posts=> true, :read_posts=> true, :update_posts=> true, :delete_posts=> true, :create_performances=> true, :read_performances=> true, :update_performances=> true, :delete_performances=> true, :manage_events=> true, :admin=> true, :type=> ""
#    assert_redirected_to "/"
#  end
#
#
#  def test_destroy_admin
#    login_as("user_admin")
#    post :destroy, :container_type=>'space', :container_id=>'1', :id=>"1"
#    assert_redirected_to :controller => "roles", :action => "index"  
#  end
#  
#  
#  def test_destroy_not_admin
#    login_as("user_normal")
#    post :destroy, :container_type=>'space', :container_id=>'1', :id=>"1"
#    assert_redirected_to "/"
#  end
#
#
#  def test_group_details
#    login_as("user_admin")
#    get :group_details, :container_type=>'space', :container_id=>'1', :group_id => "6"
#    assert_response :success    
#  end
#  
#  
#  def test_show_groups
#    login_as("user_admin")
#    get :show_groups, :container_type=>'space', :container_id=>'1'
#    assert_response :success    
#  end
#  
#  
#  def test_new_group_admin
#   login_as("user_admin")
#    get :create_group, :container_type=>'space', :container_id=>'1'
#    assert_template "create_group" 
#    assert_response :success
#  end
#  
#  
#  def test_should_not_allow_new_group_not_admin
#    login_as("user_normal")
#     get :create_group, :container_type=>'space', :container_id=>'1'
#     assert_response 403
#  end
#  
#  
#  def test_edit_group_admin
#    login_as("user_admin")
#    get :edit_group, :container_type=>'space', :container_id=>'1', :group_id=>"6"
#    assert_template "edit_group" 
#    assert_response :success
#  end
#  
#  
#  def test_should_not_allow_edit_group_not_admin
#    login_as("user_normal")
#    get :edit_group, :container_type=>'space', :container_id=>'1', :group_id=>"6"
#    assert_response 403
#  end
#  
#  
#  def test_create_group_admin
#    login_as("user_admin")
#    post :save_group, :container_type=>'space', :container_id=>'1', :group =>{:name=> "administers", :create_posts=> true, :read_posts=> true, :update_posts=> true, :delete_posts=> true, :create_performances=> true, :read_performances=> true, :update_performances=> true, :delete_performances=> true, :manage_events=> true, :admin=> true, :type=> "Group"}, :group_users =>"<div id=\"d0\">alfredo</div>\r\n\t\t\t\r\n\t   \r\n\t   \t\t<div id=\"d1\">admin</div>"
#    assert_redirected_to :controller => "roles", :action => "show_groups"  
#  end
#  
#  
#  def test_update_group_admin
#    login_as("user_admin")
#    post :update_group, :container_type=>'space', :container_id=>'1', :group_id=>"6", :name=> "administer", :create_posts=> true, :read_posts=> true, :update_posts=> true, :delete_posts=> true, :create_performances=> true, :read_performances=> true, :update_performances=> true, :delete_performances=> true, :manage_events=> true, :admin=> true, :type=> "Group", :group_users =>"<div id=\"d0\">alfredo</div>\r\n\t\t\t\r\n\t   \r\n\t   \t\t<div id=\"d1\">admin</div>"
#    assert_redirected_to :controller => "roles", :action => "show_groups"  
#  end
#  
#  
#  def test_create_bad_group_admin
#    login_as("user_admin")
#    post :save_group, :container_type=>'space', :container_id=>'1', :group =>{:name=> "administers", :create_posts=> true, :read_posts=> true, :update_posts=> true, :delete_posts=> true, :create_performances=> true, :read_performances=> true, :update_performances=> true, :delete_performances=> true, :manage_events=> true, :admin=> true, :type=> "Group"}, :group_users =>"\r\n\t\t\t\r\n\t   \r\n\t   \t\t"
#    assert_response :success    
#    assert_equal flash[:notice], "Group users can`t be blank" 
#  end
#  
# 
#   def test_delete_group_admin
#    login_as("user_admin")
#    post :delete_group, :container_type=>'space', :container_id=>'1', :group_id=>"6"
#    assert_redirected_to :controller => "roles", :action => "show_groups"  
#  end
end
