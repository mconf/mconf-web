require File.dirname(__FILE__) + '/../test_helper'

class SpacesControllerTest < ActionController::TestCase
  include CMS::AuthenticationTestHelper

  fixtures :users, :spaces, :cms_performances, :cms_roles
  
  
  def setup
    @controller = SpacesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end


def test_show_spaces_admin
  login_as("user_admin")
  get :index, :container_type=>'space', :container_id=>'1'
  assert_response :success
  assert_template "index"
end


def test_show_spaces_no_login
  get :index, :container_type=>'space', :container_id=>'1'
  assert_redirected_to :controller => "sessions", :action => "new"
end


def test_show_spaces_no_admin
  login_as("user_normal")
  get :index, :container_type=>'space', :container_id=>'1'
  assert_redirected_to "/"
end
 
 
 def test_new_admin
   login_as("user_admin")
    get :new, :container_type=>'space', :container_id=>'1'
    assert_template "new" 
    assert_response :success
   
 end
 
 
 def test_new_space_admin
   login_as("user_space1_admin")
    get :new, :container_type=>'space', :container_id=>'1'
    assert_redirected_to "/"
   
 end
 
 
 def test_new_no_admin
   login_as("user_normal")
  get :new, :container_type=>'space', :container_id=>'1'
  assert_redirected_to "/"
end


def test_new_no_login
   get :new, :container_type=>'space', :container_id=>'1'
  assert_redirected_to :controller => "sessions", :action => "new"
end


 def test_edit_admin
    login_as("user_admin")
    post :edit, :container_type=>'space', :container_id=>'1', :id=>1
    assert_template "edit" 
    assert_response :success
  end
  
  
  def test_edit_space_admin
    login_as("user_space1_admin")
    post :edit,:container_type=>'space', :container_id=>'1', :id=>1
    assert_template "edit" 
    assert_response :success
  end
  
  
  def test_edit_no_admin
    login_as("user_normal")
    post :edit, :container_type=>'space', :container_id=>'1', :id=>1
    assert_response 403
  end
  def test_edit_no_login
    post :edit, :id=>1
    assert_redirected_to :controller => "sessions", :action => "new"
  end


  def test_create_admin
    login_as("user_admin")
    post :create,:container_id=>'1', :space=>{:name=>'spacio2', :description=>'Esto es una descripcion'}
    
    assert_redirected_to :controller=>'spaces', :action=>'index'
  end
  
  
  def test_create_space_admin
    login_as("user_space1_admin")
   post :create,:container_id=>'1',  :space=>{:name=>'spacio3', :description=>'Esto es una descripcion'}
    
   assert_response 302
 end
 
  def test_create_no_admin
    login_as("user_normal")
    post :create,:container_id=>'1',  :space=>{:name=>'spacio2', :description=>'Esto es una descripcion'}
    
   assert_response 302
 end
 
 
 def test_create_no_login
   post :create,:container_id=>'1',  :space=>{:name=>'spacio2', :description=>'Esto es una descripcion'}
    
   assert_redirected_to :controller => "sessions", :action => "new"
 end
 
 
 def test_update_wrong
  login_as("user_admin")
 post :update, :id => 1,:container_type=>'space', :container_id=>'1', :space=>{:name=>'spacio5', :description=>'Esto es una descripcion'},:hola=>'adf'
   
 assert_response :success
   
 end
 
 
 def test_update_admin
  login_as("user_admin")
 post :update, :id => 1,:container_type=>'space', :container_id=>'1', :space=>{:name=>'spacio5', :description=>'Esto es una descripcion'},:role=>{:name=>'administrator'}
    
 assert_response :success
   
 end
 
 
 def test_update_space_admin
  login_as("user_space1_admin")
 post :update,:id=> 1, :container_type=>'space', :container_id=>'1', :space=>{:name=>'spacio2', :description=>'Esto es una descripcion'}
    
  assert_response :success
 end
 
 
 def test_update_no_admin
   login_as("user_normal")
    post :update,:container_type=>'space', :container_id=>'1',:id=>1,:container_type=>'space', :container_id=>'1',  :space=>{:name=>'spacio2', :description=>'Esto es una descripcion'}
    
   assert_response 403
 end
 
 
 def test_update_no_login
   post :update,:container_type=>'space', :container_id=>'1',:id=>1, :space=>{:name=>'spacio2', :description=>'Esto es una descripcion'}
    
   assert_redirected_to :controller => "sessions", :action => "new"
 end
 
 
 def test_destroy_admin
   login_as("user_admin")
   post :destroy,:container_type=>'space', :container_id=>'1',:id=>1
   assert flash[:notice].include?('successfully')
   assert_redirected_to spaces_url
 end
 
 def test_destroy_no_admin
   login_as("user_normal")
  post :destroy,:container_type=>'space', :container_id=>'1',:id=>1
  assert_redirected_to "/"
end


end
