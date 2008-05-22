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
  get :index
  assert_response :success
  assert_template "index"
end
def test_show_spaces_no_login
  get :index
  assert_redirected_to :controller => "sessions", :action => "new"
end

def test_show_spaces_no_admin
  login_as("user_normal")
  get :index
  assert_redirected_to :controller => "events", :action => "show"
   
 end
 def test_new_admin
   login_as("user_admin")
    get :new
    assert_template "new" 
    assert_response :success
   
 end
 
 
 def test_new_space_admin
   login_as("user_space1_admin")
    get :new
    assert_redirected_to :controller => "events", :action => "show"
   
 end
 
 def test_new_no_admin
   login_as("user_normal")
  get :new
  assert_redirected_to :controller => "events", :action => "show"
end
def test_new_no_login
   get :new
  assert_redirected_to :controller => "sessions", :action => "new"
end
 def test_edit_admin
    login_as("user_admin")
    post :edit, :id=>1
    assert_template "edit" 
    assert_response :success
  end
  #def test_edit_space_admin
   # login_as("user_space1_admin")
   # post :edit, :id=>1
   # assert_template "edit" 
    #assert_response :success
  #   end
  
  def test_edit_no_admin
    login_as("user_normal")
    post :edit, :id=>1
    assert_response 403
  end
  def test_edit_no_login
    post :edit, :id=>1
    assert_redirected_to :controller => "sessions", :action => "new"
  end

  def test_create_admin
    login_as("user_admin")
    post :create, :name=>'spacio2', :description=>'Esto es una descripcion'
    
    assert_response :success
  end
  def test_create_space_admin
    login_as("user_space1_admin")
   post :create, :name=>'spacio3', :description=>'Esto es una descripcion'
   assert_response 302
  end
  def test_create_no_admin
    login_as("user_normal")
    post :create, :name=>'spacio3', :description=>'Esto es una descripcion'
   assert_response 302
 end
 def test_create_no_login
   post :create, :name=>'spacio3', :description=>'Esto es una descripcion'
   assert_redirected_to :controller => "sessions", :action => "new"
 end
 def test_update_admin
  login_as("user_admin")
 post :update, :id => 1, :name=>'spacio1', :description=>'he cambiado la descripción'
 assert_response :success
   
 end
 def test_update_space_admin
  login_as("user_space1_admin")
 post :update,:id=> 1, :name=>'spacio3', :description=>'Esto es una descripcion'
  assert_response :success
 end
 
 def test_update_no_admin
   login_as("user_normal")
    post :update,:id=>1, :name=>'spacio3', :description=>'Esto es una descripcion'
   assert_response 403
 end
 def test_update_no_login
   post :update,:id=>1, :name=>'spacio3', :description=>'Esto es una descripcion'
   assert_redirected_to :controller => "sessions", :action => "new"
 end
 
 def test_destroy_admin
   login_as("user_admin")
   post :destroy,:id=>1
   assert flash[:notice].include?('successfully')
 end
 def test_destroy_no_admin
   login_as("user_normal")
  post :destroy,:id=>1
  assert_redirected_to :controller=>'events' , :action=>'show'
end


end
