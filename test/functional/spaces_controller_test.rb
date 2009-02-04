require File.dirname(__FILE__) + '/../test_helper'

# Todos los tests que necesitan revisión están comentados

class SpacesControllerTest < ActionController::TestCase
  include ActionController::AuthenticationTestHelper

  fixtures :users, :spaces, :performances, :roles
  
  
  def setup
    @controller = SpacesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end


def test_show_spaces_admin
  login_as("user_admin")
  get :index
  assert_response :success
  assert_template "index"
end


#def test_show_spaces_no_login
#  get :index
#  assert_redirected_to :controller => "sessions", :action => "new"
#end
#
#
#def test_show_spaces_no_admin
#  login_as("user_normal")
#  get :index
#  assert_redirected_to "/"
#end
 
 
 def test_new_admin
   login_as("user_admin")
    get :new
    assert_template "new" 
    assert_response :success
   
 end
 
 
 def test_new_space_admin
   login_as("user_space1_admin")
    get :new
    assert_redirected_to "/"
   
 end
 
 
 def test_new_no_admin
   login_as("user_normal")
  get :new
  assert_redirected_to "/"
end


def test_new_no_login
   get :new
  assert_response :unauthorized
end


 def test_edit_admin
    login_as("user_admin")
    get :edit, :id=>1
    assert_template "edit" 
    assert_response :success
  end
  
  
#  def test_edit_space_admin
#    login_as("user_space1_admin")
#    get :edit, :id=>1
#    assert_template "edit" 
#    assert_response :success
#  end
  
  
#  def test_edit_no_admin
#    login_as("user_normal")
#    get :edit, :id=>1
#    assert_response 403
#  end
  
  def test_edit_no_login
    get :edit, :id=>1
    assert_response :unauthorized
  end


  def test_create_admin
    login_as("user_admin")
    post :create, :space=>{:name=>'spacio2', :description=>'Esto es una descripcion'}
    
    assert_redirected_to :controller=>'spaces', :action=>'index'
  end
  
  
  def test_create_space_admin
    login_as("user_space1_admin")
   post :create, :space=>{:name=>'spacio3', :description=>'Esto es una descripcion'}
    
   assert_response 302
 end
 
  def test_create_no_admin
    login_as("user_normal")
    post :create, :space=>{:name=>'spacio2', :description=>'Esto es una descripcion'}
    
   assert_response 302
 end
 
 
 def test_create_no_login
   post :create, :space=>{:name=>'spacio2', :description=>'Esto es una descripcion'}
    
   assert_response :unauthorized
 end

# def test_update_admin
#  login_as("user_admin")
# put :update, :id => 'Public', :space=>{:name=>'spacio5', :description=>'Esto es una descripcion'},:role=>{:name=>'administrator'}
#    
# assert_response 302
#   
# end
# 
# 
# def test_update_space_admin
#  login_as("user_space1_admin")
# post :update,:id=> 1, :container_type=>'space', :container_id=>'1', :space=>{:name=>'spacio2', :description=>'Esto es una descripcion'}
#    
#  assert_response 302
# end
# 
# 
# def test_update_no_admin
#   login_as("user_normal")
#    post :update,:id=>'Public',  :space=>{:name=>'spacio2', :description=>'Esto es una descripcion'}
#    
#   assert_response 403
# end
 
 
 def test_update_no_login
   post :update,:id=>1, :space=>{:name=>'spacio2', :description=>'Esto es una descripcion'}
    
   assert_response :unauthorized
 end

 def test_destroy_admin
   login_as("user_admin")
   post :destroy,:id=>'Public'
   assert flash[:notice].include?('successfully')
   assert_redirected_to spaces_url
 end
 
 def test_destroy_no_admin
   login_as("user_normal")
  post :destroy,:id=>'Public'
  assert_redirected_to "/"
end


end
