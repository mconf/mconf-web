require File.dirname(__FILE__) + '/../test_helper'

class ProfilesControllerTest < ActionController::TestCase
    
    fixtures :users, :profiles, :spaces
    
     def test_show_owner
       login_as("user_normal")
      get :show, :user_id=>25, :space_id => '1'
      assert_response :success
      assert_template "show"  
    end
    
    def test_show_no_owner
      login_as("user_normal")
      get :show, :user_id=>24, :space_id => '1'
      assert_redirected_to :controller => "home", :action => "index"
      assert flash[:notice].include?('not allowed')
    end
    def test_show_no_login
      get :show, :user_id=>25, :space_id => '1'
      assert_redirected_to :controller => "sessions", :action => "new"
    
    end
    
    def test_new_no_profile
      login_as("user_alfredo")
      get :new, :user_id=>23, :space_id => '1'
      assert_response :success
      assert_template "new"  
    end
    
    def test_new_profile
      login_as("user_normal")
      get :new, :user_id=>25, :space_id => '1'
      assert_redirected_to :controller => "profiles", :action => "show"
      assert flash[:notice].include?(' already a profile')
    end
   
        
     def test_edit_owner
       login_as("user_normal")
      get :edit, :user_id=>25, :space_id => '1'
      assert_response :success
      assert_template "edit"  
       
     end
     
     def test_edit_no_owner
       login_as("user_normal")
      get :edit, :user_id=>24, :space_id => '1'
      assert_redirected_to :controller => "home", :action => "index"
      assert flash[:notice].include?('not allowed')
    end
  
    def test_create_no_profile
      login_as("user_alfredo")
      post :create, :space_id => '1', :user_id=> 23, :profile =>{:name=>'prueba',:lastname=>'pruebaprueba', :organization=>'dit', :phone=>'45845646', :mobile=>'654895623', :fax=>'915478956', :address=>'Callejando 5', :city=>'madrid', :zipcode=>'458451', :province=>'madrid', :country=>'spain'}
      assert :success
      assert_redirected_to :controller=>'profiles', :action=>'show'
      
    end
    
    def test_create_profile
      login_as("user_normal")
      post :create, :space_id => '1', :user_id=> 25, :profile=>{ :name=>'prueba',:lastname=>'pruebaprueba', :organization=>'dit', :phone=>'45845646', :mobile=>'654895623', :fax=>'915478956', :address=>'Callejando 5', :city=>'madrid', :zipcode=>'458451', :province=>'madrid', :country=>'spain'}
      assert_redirected_to :controller=>'profiles', :action=>'show'
      assert flash[:notice].include?('already a profile')
    end
    
     def test_update_wrong
      login_as("user_normal")
       post :update, :space_id => '1',:user_id=>25, :lastname=>'pruebaprueba', :organization=>'dit', :phone=>'45845646', :mobile=>'654895623', :fax=>'915478956', :address=>'Callejando 5', :city=>'madrid', :zipcode=>'458451', :province=>'madrid', :country=>'spain'
     assert :success
   end
   
    def test_update_owner
      login_as("user_normal")
      post :update, :space_id => '1', :user_id=>25, :profile=>{:name=>'prueba',:lastname=>'pruebaprueba', :organization=>'dit', :phone=>'45845646', :mobile=>'654895623', :fax=>'915478956', :address=>'Callejando 5', :city=>'madriddd', :zipcode=>'458451', :province=>'madrid', :country=>'spain'}
      assert_response :success
      assert flash[:notice].include?('successfully')
    end
    
    def test_update_no_owner
      login_as("user_normal")
      post :update, :space_id => '1', :user_id=>24,:profile=>{ :name=>'prueba',:lastname=>'pruebaprueba', :organization=>'dit', :phone=>'45845646', :mobile=>'654895623', :fax=>'915478956', :address=>'Callejando 5', :city=>'madriddd', :zipcode=>'458451', :province=>'madrid', :country=>'spain'}
      assert_redirected_to :controller => "home", :action => "index"
      assert flash[:notice].include?('not allowed')
    end
    
     def test_update_no_login
      
      post :update, :space_id => '1', :user_id=>25,:profile=>{ :name=>'prueba',:lastname=>'pruebaprueba', :organization=>'dit', :phone=>'45845646', :mobile=>'654895623', :fax=>'915478956', :address=>'Callejando 5', :city=>'madriddd', :zipcode=>'458451', :province=>'madrid', :country=>'spain'}
     assert_redirected_to :controller => "sessions", :action => "new"
     
   end
   
   def test_destroy_owner
     login_as("user_normal")
     post :destroy, :space_id => '1', :user_id=> 25
     assert_redirected_to space_user_profile_url(:space_id => '1', :user_id=>'25')
      assert flash[:notice].include?('successfully')
   assert_response 302
 end
 
 def test_destroy_no_owner
     login_as("user_normal")
     post :destroy, :space_id => '1', :user_id=> 24
     assert_redirected_to :controller => "home", :action => "index"
     assert flash[:notice].include?('not allowed')
   assert_response 302
 end
   
   def test_hcard_no_profile
      login_as("user_alfredo")
      get :hcard, :space_id => '1', :user_id=>23
      assert_redirected_to :controller => "profiles", :action => "new"
     assert flash[:notice].include?('create your profile')
   end
   
   def test_hcard_owner
     login_as("user_normal")
     get :hcard, :space_id => '1', :user_id=>25
  assert_response :success
  assert_template "_hcard"
end

   def test_hcard_no_owner
     login_as("user_normal")
     get :hcard, :space_id => '1', :user_id=>24
     assert_redirected_to :controller => "home", :action => "index"
     assert flash[:notice].include?('not allowed')
   assert_response 302
 end
 
 def test_vcard_owner
   login_as("user_normal")
     get :vcard, :space_id => '1', :user_id=>25
  assert_response :success
end

def test_vcard_no_owner
   login_as("user_normal")
     get :vcard, :space_id => '1', :user_id=>24
  assert_redirected_to :controller => "home", :action => "index"
     assert flash[:notice].include?('not allowed')
   assert_response 302
 end
    
end
