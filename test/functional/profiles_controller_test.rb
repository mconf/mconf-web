require File.dirname(__FILE__) + '/../test_helper'

class ProfilesControllerTest < ActionController::TestCase
    
    fixtures :users, :profiles
    def test_index_owner
      login_as("user_normal")
      get :index, :id=>2
      assert_response :success
      assert_template "index"  
    end
    
     def test_show_owner
       login_as("user_normal")
      get :show, :id=>2
      assert_response :success
      assert_template "show"  
    end
    
    def test_show_no_owner
      login_as("user_normal")
      get :show, :id=>1
      assert_redirected_to :controller => "events", :action => "show"
      assert flash[:notice].include?('not allowed')
    end
    def test_show_no_login
      get :show, :id=>1
      assert_redirected_to :controller => "sessions", :action => "new"
    
    end
    
    def test_new_no_profile
      login_as("user_alfredo")
      get :new
      assert_response :success
      assert_template "new"  
    end
    
    def test_new_profile
      login_as("user_normal")
      get :new
      assert_redirected_to :controller => "profiles", :action => "show"
      assert flash[:notice].include?(' already a profile')
    end
   
        
     def test_edit_owner
       login_as("user_normal")
      get :show, :id=>2
      assert_response :success
      assert_template "show"  
       
     end
     
     def test_edit_no_owner
       login_as("user_normal")
      get :show, :id=>1
      assert_redirected_to :controller => "events", :action => "show"
      assert flash[:notice].include?('not allowed')
    end
    
    def test_create_no_profile
      login_as("user_alfredo")
      post :create, :name=>'prueba',:lastname=>'pruebaprueba', :organization=>'dit', :phone=>'45845646', :mobile=>'654895623', :fax=>'915478956', :address=>'Callejando 5', :city=>'madrid', :zipcode=>'458451', :province=>'madrid', :country=>'spain'
      assert :success
      
    end
    
    def test_create_profile
      login_as("user_normal")
      post :create, :name=>'prueba',:lastname=>'pruebaprueba', :organization=>'dit', :phone=>'45845646', :mobile=>'654895623', :fax=>'915478956', :address=>'Callejando 5', :city=>'madrid', :zipcode=>'458451', :province=>'madrid', :country=>'spain'
      assert_redirected_to :controller=>'profiles', :action=>'show'
      assert flash[:notice].include?('already a profile')
    end
    
    def test_update_owner
      login_as("user_normal")
      post :update, :id=>2, :name=>'prueba',:lastname=>'pruebaprueba', :organization=>'dit', :phone=>'45845646', :mobile=>'654895623', :fax=>'915478956', :address=>'Callejando 5', :city=>'madriddd', :zipcode=>'458451', :province=>'madrid', :country=>'spain'
      assert_response :success
      assert flash[:notice].include?('successfully')
    end
    
    def test_update_no_owner
      login_as("user_normal")
      post :update, :id=>1, :name=>'prueba',:lastname=>'pruebaprueba', :organization=>'dit', :phone=>'45845646', :mobile=>'654895623', :fax=>'915478956', :address=>'Callejando 5', :city=>'madriddd', :zipcode=>'458451', :province=>'madrid', :country=>'spain'
      assert_redirected_to :controller => "events", :action => "show"
      assert flash[:notice].include?('not allowed')
    end
    
     def test_update_no_login
      
      post :update, :id=>2, :name=>'prueba',:lastname=>'pruebaprueba', :organization=>'dit', :phone=>'45845646', :mobile=>'654895623', :fax=>'915478956', :address=>'Callejando 5', :city=>'madriddd', :zipcode=>'458451', :province=>'madrid', :country=>'spain'
      assert_redirected_to :controller => "sessions", :action => "new"
     
   end
   
   def test_destroy_owner
     login_as("user_normal")
     post :destroy, :id=> 2
     assert_redirected_to profiles_url
      assert flash[:notice].include?('successfully')
   assert_response 302
 end
 
 def test_destroy_no_owner
     login_as("user_normal")
     post :destroy, :id=> 1
     assert_redirected_to :controller => "events", :action => "show"
     assert flash[:notice].include?('not allowed')
   assert_response 302
 end
   
   def test_hcard_owner
     login_as("user_normal")
     get :hcard, :id=>25
  assert_response :success
  assert_template "hcard"  
  
   end
   def test_hcard_no_owner
     login_as("user_normal")
     get :hcard, :id=>24
     assert_redirected_to :controller => "events", :action => "show"
     assert flash[:notice].include?('not allowed')
   assert_response 302
 end
 
 def test_vcard_owner
   login_as("user_normal")
     get :vcard, :id=>2
  assert_response :success
end

def test_vcard_no_owner
   login_as("user_normal")
     get :vcard, :id=>1
  assert_redirected_to :controller => "events", :action => "show"
     assert flash[:notice].include?('not allowed')
   assert_response 302
 end
    
    #def test_should_get_index
      #get :index
      #assert_response :success
      #assert_not_nil assigns(:profiles)
    #end

    #def test_should_get_new
      #get :new
      #assert_response :success
    #end

    #def test_should_create_profile
      #assert_difference('Profile.count') do
        #post :create, :profile => { }
      #end

      #assert_redirected_to profile_path(assigns(:profile))
    #end

    #def test_should_show_profile
      #get :show, :id => profiles(:one).id
      #assert_response :success
    #end

  #  def test_should_get_edit
     # get :edit, :id => profiles(:one).id
      #assert_response :success
    #end

    #def test_should_update_profile
      #put :update, :id => profiles(:one).id, :profile => { }
      #assert_redirected_to profile_path(assigns(:profile))
    #end

    #def test_should_destroy_profile
      #assert_difference('Profile.count', -1) do
        #delete :destroy, :id => profiles(:one).id
      #end

      #assert_redirected_to profiles_path
    #end
end
