require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ProfilesController do
  #integrate_views
  include ActionController::AuthenticationTestHelper
  fixtures :users , :spaces , :profiles
  
  def mock_profile(stubs={})
    @mock_profile ||= mock_model(Profile, stubs)
  end
  
  
  describe "responding to GET show" do

    describe "when you are logged in" do
      describe "as SuperAdmin" do
        before(:each) do
          login_as(:user_admin)
        end
        describe "in a private space" do
          before(:each) do
            @space = spaces(:private_no_roles)
            @user = users(:user_normal2)
          end
          
          it "should let the user to see the user's profile of this space" do
            get :show, :user_id => @user.id
            assert_response 200
          end
          
          it "should redirect to the associated user's profile view " do
            get :show , :user_id => @user.id
            response.should {render :template => "show"}
          end
          
        end
        
        describe "in the public space" do
          before(:each) do
            @space = spaces(:public)
            @user = users(:user_normal2)
          end
          
          it "should let the user to see the user's profile of a user of this space" do
            get :show, :user_id => @user.id
            assert_response 200
          end
          
          it "should redirect to the associated user view" do
            get :show, :user_id => @user.id
            response.should {render :template => "show"}
          end    
        end
    
      end
      describe "as normal_user" do
        before(:each) do
          login_as(:user_normal)
        end
        describe "in a private space where the user has the role Admin " do
          before(:each) do
            @space = spaces(:private_admin)
            @user = users(:user_normal2)
          end
          
          it "should let the user to see the user's profile of a user of this space" do
            get :show , :user_id => @user.id
            assert_response 200
          end
          it "should redirect to the associated user view" do
            get :show, :user_id => @user.id
            response.should {render :template => "show"}
          end 
          
        end
        
        describe "in a private space where the user has the role User" do
          before(:each) do
            @space = spaces(:private_user)
            @user = users(:user_normal2)
          end
          
          it "should let the user to see the user's profile of a user of this space" do
            get :show, :user_id => @user.id
            assert_response 200
          end
          
        end
        describe "in a private space where the user has the role Invited " do
          before(:each) do
            @space = spaces(:private_invited)
            @user = users(:user_normal2)
          end
          
          it "should let the user to see the user's profile of a user of this space" do
            get :show, :user_id => @user.id
            assert_response 200
          end
          
        end
        
        describe "in a private space where the user has not any roles" do
          before(:each) do
            @space = spaces(:private_no_roles)
            @user = users(:aaron2)
          end
          
          it "should let the user to see the user's profile of a user of this space" do
            get :show , :user_id => @user.id
            assert_response 403
          end       
        end
               
        describe "in the public space" do
          
          before(:each) do
            @space = spaces(:public)
            @user = users(:user_normal2)
          end
          
          it "should let the user to see the user's profile of a user of this space where the user has roles" do
            get :show, :user_id => @user.id
            assert_response 200
          end   
        end 
      end 
    end
    
    describe "if you are not logged in" do
      describe "in a private space" do
        before(:each) do
          @space = spaces(:private_no_roles)
          @user = users(:aaron2)
        end
        
        it "should NOT let the user to see an user profile" do
          get :show, :user_id => @user.id
          assert_response 401
        end
      end
      
      describe "in the public space" do
        before(:each) do
          @space = spaces(:public)
          @user = users(:user_normal2)
        end
        
        it "should NOT let the user to see an user profile" do
          get :show,  :user_id => @user.id
          assert_response 401
        end  
      end 
    end   
  end

############################################

  describe "responding to GET new" do
    describe "when you are logged in" do
      describe "as super Admin" do
        describe "which have a profile"do
          before(:each)do
            login_as(:user_admin)
          end
          it "should NOT let the user to create his profile if he already has one" do
              get :new, :user_id => users(:user_admin)           
              flash[:error].should == "You already have a profile."
              response.should redirect_to(user_profile_path(users(:user_admin)))
          end                    
        end
        describe "which have not a profile" do
          before(:each)do
            login_as(:user_admin2)
          end 
          it "should let the user to create his profile if he hasn't one" do
              get :new, :user_id => users(:user_admin2).id
              assert_response 200
          end           
        end                    
      end
      
      describe "as a normal user" do
        describe "which have a profile" do
          before(:each)do
            login_as(:user_normal)
          end
        
          it "should NOT let the user to create his profile if he already has one" do
            get :new , :user_id => users(:user_normal).id
            flash[:error].should == "You already have a profile."
            response.should redirect_to(user_profile_path(users(:user_normal)))           
          end          
        end
        describe "which have not a profile" do
          before(:each)do
            login_as(:user_normal3)
          end
        
          it "should let the user to create his profile" do
            get :new , :user_id => users(:user_normal3).id
            assert_response 200
          end          
        end          
      end
    end
    describe "if you are not logged in" do
      it "should let the user to create a new account" do
        get :new , :user_id => users(:user_admin).id
        assert_response 401
      end
    end
  end

####################################
  describe "responding to GET edit" do
    describe "when you are logged in" do
      describe "as SuperAdmin" do
        before(:each) do
          login_as(:user_admin)
        end
        describe "in a private space" do
          before(:each) do
            @space = spaces(:private_no_roles)
            @user = users(:aaron2)
          end
          
          it "should let the user to edit the profile of a user of this space" do
            get :edit, :user_id => @user
            assert_response 200
          end
          
          it "should let the user to edit his own profile" do
            get :edit, :user_id => users(:user_admin)
            assert_response 200
          end          
          
          it "should redirect to the associated user view" do
            get :edit , :user_id => @user.id
            response.should {render :template => "edit"}
          end
          
        end
        
        describe "in the public space" do
          before(:each) do
            @space = spaces(:public)
            @user = users(:user_normal2)
          end
          
          it "should let the user to edit profile of a user of this space" do
            get :edit, :user_id => @user.id
            assert_response 200
          end

          it "should let the user to edit his own profile" do
            get :edit, :user_id => users(:user_admin)
            assert_response 200
          end  
          
          it "should redirect to the associated user view" do
            get :edit, :user_id => @user.id
            response.should {render :template => "edit"}
          end    
        end
    
      end
      describe "as normal_user" do
        before(:each) do
          login_as(:user_normal)
        end
        describe "in a private space where the user has the role Admin " do
          before(:each) do
            @space = spaces(:private_admin)
            @user = users(:user_normal2)
          end
          
          it "should NOT let the user to edit the profile of a user of this space" do
            get :edit , :user_id => @user
            assert_response 403
          end
          
          it "should let the user to edit his own profile and redirect to the associated user view" do
            get :edit , :user_id => users(:user_normal)
            assert_response 200
            response.should {render :template => "edit"}            
          end                           
        end
        
        describe "in a private space where the user has the role User" do
          before(:each) do
            @space = spaces(:private_user)
            @user = users(:user_normal2)
          end
          
          it "should NOT let the user to edit the profile of a user of this space" do
            get :edit, :user_id => @user
            assert_response 403
          end
          
          it "should let the user to edit his own profile and redirect to the associated user view" do
            get :edit , :user_id => users(:user_normal)
            assert_response 200
            response.should {render :template =>"edit"}         
          end 
          
        end
        describe "in a private space where the user has the role Invited " do
          before(:each) do
            @space = spaces(:private_invited)
            @user = users(:user_normal2)
          end
          
          it "should NOT let the user to edit the profile of a user of this space" do
            get :edit, :user_id => @user
            assert_response 403
          end
          
          it "should let the user to edit his own profile and redirect to the associated user view" do
            get :edit , :user_id => users(:user_normal)
            assert_response 200
            response.should {render :template => "edit"}         
          end 
          
        end
        
        describe "in a private space where the user has not any roles" do
          before(:each) do
            @space = spaces(:private_no_roles)
            @user = users(:aaron2)
          end
          
          it "should NOT let the user to edit the profile of a user of this space" do
            get :edit , :user_id => @user
            assert_response 403
          end
          
          it "should let the user to edit his own profile and redirect to the associated user view" do
            get :edit , :user_id => users(:user_normal)
            assert_response 200
            response.should {render :template => "edit"}            
          end 
        end
        
        describe "without space" do
          before(:each) do
            @user = users(:user_normal2)
          end
          
          it "should NOT let the user to edit the profile of a user of this space" do
            get :edit, :user_id => @user
            assert_response 403
          end
          
          it "should let the user to edit his own profile and redirect to the associated user view" do
            get :edit , :user_id => users(:user_normal)
            assert_response 200
            response.should {render :template => "edit"}            
          end 
          
        end
        
        
        describe "in the public space" do
          
          before(:each) do
            @space = spaces(:public)
            @user = users(:user_normal2)
          end
          
          it "should NOT let the user to edit the profile of a user of this space" do
            get :edit, :user_id => @user
            assert_response 403
          end
          
          it "should let the user to edit his own profile and redirect to the associated user view" do
            get :edit , :user_id => users(:user_normal)
            assert_response 200
            response.should {render :template => "edit"}            
          end 
          
        end 
      end
      
      describe "as a user without profile" do
        
        before(:each) do
          login_as(:user_normal3)
        end
        it "should NOT let the user to edit the profile and" do
          get :edit, :user_id => users(:user_normal3)
          response.should redirect_to(new_user_profile_path(users(:user_normal3)))
          flash[:notice].should == "You must create your profile first"
        end
        
      end
    end
    
    describe "if you are not logged in" do
      describe "in a private space" do
        before(:each) do
          @space = spaces(:private_no_roles)
          @user = users(:aaron2)
        end
        
        it "should NOT let the user to edit the profile of a user of this space" do
          get :edit, :user_id => @user.id
          assert_response 401
        end
      end
      
      describe "in the public space" do
        before(:each) do
          @space = spaces(:public)
          @user = users(:user_normal2)
        end
        
        it "should NOT let the user to edit profile of a user of this space" do
          get :edit,  :user_id => @user.id
           assert_response 401
        end  
      end 
    end   
  end



########################################33

  describe "responding to POST create" do

    describe "with valid params" do
      before(:each)do
        @valid_attributes = {:name => "pepe", 
                             :lastname => "jugon",
                             :phone => "673548798",
                             :city => "Madrid",
                             :country => "Spain",
                             :organization => "Dit"}
      end
      describe "when you are logged in" do
        describe "as super Admin" do
          before(:each)do
            login_as(:user_admin)
          end
        
          it "should NOT let the user to create a profile if he has one" do
            assert_no_difference 'Profile.count' do
              post :create, :user_id => users(:user_admin), :profile=> @valid_attributes
              response.should redirect_to(user_profile_path(users(:user_admin)))
            end
          end
          it "should let the Admin to create a profile if a User hasn't one" do
            pending
            assert_difference 'Profile.count' do
              post :create, :user_id => users(:user_normal3), :profile=> @valid_attributes
              assert_response 200
            end
          end  
        end
      
        describe "as a normal user" do
          describe " with profile" do
            before(:each)do
              login_as(:user_normal)
            end
        
            it "should NOT let the user to create a profile" do
              assert_no_difference 'Profile.count' do
                post :create, :user_id => users(:user_normal), :profile=> @valid_attributes
                response.should redirect_to(user_profile_path(users(:user_normal)))
              end
            end
            it "should NOT let the user to create the profile of other user" do
              assert_no_difference 'Profile.count' do
                post :create, :user_id => users(:user_normal3), :profile=> @valid_attributes
                assert_response 403
              end
            end                      
      
          end
          
          describe "without profile" do
            before(:each)do
              login_as(:user_normal3)
            end
        
            it "should let the user to create a profile" do
              assert_difference 'Profile.count' do
                post :create, :user_id => users(:user_normal3), :profile=> @valid_attributes
                response.should redirect_to(user_profile_path(users(:user_normal3))) 
              end
            end
            it "should NOT let the user to create the profile of other user" do
              assert_no_difference 'Profile.count' do
                post :create, :user_id => users(:user_normal), :profile=> @valid_attributes
                assert_response 403
              end
            end             
          end     
        end
      end
      describe "if you are not logged in" do
        it "should NOT let the user to create a profile" do
          assert_no_difference 'Profile.count' do
            post :create, :user_id => users(:user_normal), :profile=> @valid_attributes
            assert_response 401
          end
        end
      end              
    end
    
    describe "with invalid params" do
      
      before(:each)do
        @invalid_attributes = {:name => ""}
      end
      
      describe "when you are logged in" do
        describe "as super Admin" do
          describe "with profile" do
            before(:each)do
              login_as(:user_admin)
            end
        
            it "should NOT let the user to create a profile" do
              assert_no_difference 'Profile.count' do
                post :create, :user_id => users(:user_admin),:profile=> @invalid_attributes
                response.should {render :template =>"new"}
              end
            end            
          end
          describe "without profile" do
            before(:each)do
              login_as(:user_admin2)
            end
        
            it "should NOT let the user to create his profile" do
              assert_no_difference 'Profile.count' do
                post :create,  :user_id => users(:user_admin2), :profile=> @invalid_attributes
                response.should {render :template =>"new"}
              end
            end                        
            
          end
        end
      
        describe "as a normal user" do
          describe "with profile" do
            before(:each)do
              login_as(:user_normal)
            end
        
            it "should NOT let the user to create another profile" do
              assert_no_difference 'Profile.count' do
                post :create, :user_id => users(:user_normal), :profile=> @invalid_attributes
                response.should {render :template =>"new"}
              end
            end  
          end
          describe "without profile" do
            before(:each)do
              login_as(:user_normal3)
            end
        
            it "should NOT let the user to create his profile" do
              assert_no_difference 'User.count' do
                post :create, :user_id => users(:user_normal3), :profile=> @invalid_attributes
                response.should {render :template =>"new"}
              end
            end  
          end        
        end
      end
      describe "if you are not logged in" do
        it "should NOT let the user to create the profile" do
          assert_no_difference 'Profile.count' do
            post :create, :user_id => users(:user_normal), :profile => @invalid_attributes
            response.should {render :template =>"new"}            
          end
        end
      end                  
    end
  end

########################################
  describe "responding to PUT udpate" do

    describe "with valid params" do
      before(:each)do
       @valid_attributes = {:name => "pepe", 
                             :lastname => "jugon",
                             :phone => "673548798",
                             :city => "Madrid",
                             :country => "Spain",
                             :organization => "Dit"}
      end      
      describe "when you are logged in" do
        describe "as SuperAdmin" do
          before(:each) do
            login_as(:user_admin)
          end
          describe "in a private space" do
            before(:each) do
              @space = spaces(:private_no_roles)
              @user = users(:user_normal2)
            end
          
            it "should let the user to UPDATE the profile of a user of this space" do
              put :update, :user_id => @user, :profile => @valid_attributes              
              assert_response 200
              response.should {render :template => "show"}
            end
            
            it "should let the user to UPDATE his profile" do
              put :update, :user_id => users(:user_admin), :profile => @valid_attributes              
              assert_response 200
              response.should {render :template => "show"}
            end            
          end
        
          describe "in the public space" do
            before(:each) do
              @space = spaces(:public)
              @user = users(:user_normal2)
            end
          
            it "should let the user to UPDATE the profile of a user of this space" do
              put :update, :user_id => @user, :profile => @valid_attributes
              assert_response 200
              response.should {render :template => "show"}
            end
            it "should let the user to UPDATE his profile" do
              put :update, :user_id => users(:user_admin), :profile => @valid_attributes              
              assert_response 200
              response.should {render :template => "show"}
            end              
          end
    
        end
        describe "as normal_user" do
          before(:each) do
            login_as(:user_normal)
          end
          describe "in a private space where the user has the role Admin " do
            before(:each) do
              @space = spaces(:private_admin)
              @user = users(:user_normal2)
            end
          
            it "should NOT let the user to UPDATE the profile of a user of this space" do
              put :update , :user_id => @user, :profile => @valid_attributes
              assert_response 403
            end
            
            it "should let the user to UPDATE his profile" do
              put :update , :user_id => users(:user_normal), :profile => @valid_attributes
              assert_response 200
              response.should {render :template => "show"}
            end
          end
        
          describe "in a private space where the user has the role User" do
            before(:each) do
              @space = spaces(:private_user)
              @user = users(:user_normal2)
            end
          
            it "should NOT let the user to UPDATE the profile of a user of this space" do
              put :update, :user_id => @user, :profile => @valid_attributes
              assert_response 403
            end
            it "should let the user to UPDATE his profile" do
              put :update , :user_id => users(:user_normal), :profile => @valid_attributes
              assert_response 200
              response.should {render :template => "show"}
            end
          
          end
          describe "in a private space where the user has the role Invited " do
            before(:each) do
              @space = spaces(:private_invited)
              @user = users(:user_normal2)
            end
          
            it "should NOT let the user to UPDATE the profile of a user of this space" do
              put :update, :user_id => @user, :profile => @valid_attributes
              assert_response 403
            end
            
            it "should let the user to UPDATE his profile" do
              put :update , :user_id => users(:user_normal), :profile => @valid_attributes
              assert_response 200
              response.should {render :template => "show"}
            end
          
          end
        
          describe "in a private space where the user has not any roles" do
            before(:each) do
              @space = spaces(:private_no_roles)
              @user = users(:user_normal2)
            end
          
            it "should NOT let the user to UPDATE the profile of a user of this space" do
              put :update , :user_id => @user.id, :profile => @valid_attributes
              assert_response 403
            end
            
            it "should let the user to UPDATE his profile" do
              put :update , :user_id => users(:user_normal), :profile => @valid_attributes
              assert_response 200
              response.should {render :template => "show"}
            end
            
          end
        
          describe "without space" do
            before(:each) do
              @user = users(:user_normal2)                          
            end
          
            it "should NOT let the user to UPDATE the profile of a user of this space" do
              put :update, :user_id => @user.id, :profile => @valid_attributes
              assert_response 403
            end
            
            it "should let the user to UPDATE his profile" do
              put :update , :user_id => users(:user_normal), :profile => @valid_attributes
              #no tiene mucho sentido este test
              assert_response 200
              response.should {render :template => "show"}
            end
          end
        
        
          describe "in the public space" do
          
            before(:each) do
              @space = spaces(:public)
              @user = users(:user_normal2)
            end
          
            it "should NOT let the user to UPDATE the profile of a user of this space" do
              put :update, :user_id => @user.id, :profile => @valid_attributes
              assert_response 403
            end
            
            it "should let the user to UPDATE his profile" do
              put :update , :user_id => users(:user_normal), :profile => @valid_attributes
              assert_response 200
              response.should {render :template => "show"}
            end
            
          end 
        end 
      end
    
      describe "if you are not logged in" do
        describe "in a private space" do
          before(:each) do
            @space = spaces(:private_no_roles)
            @user = users(:user_normal2)
          end
        
          it "should NOT let the user to UPDATE the profile of a user of this space" do
            put :update, :user_id => @user.id, :profile => @valid_attributes
            assert_response 401
          end
        end
      
        describe "in the public space" do
          before(:each) do
            @space = spaces(:public)
            @user = users(:user_normal2)
          end
        
          it "should NOT let the user to UDATE the profile of a user of this space" do
            put :update,  :user_id => @user.id, :profile => @valid_attributes
            assert_response 401
          end  
        end 
      end            
    end
    
    describe "with invalid params" do
      before(:each)do
         @invalid_attributes = {:name => ""}
      end
      describe "when you are logged in" do
        describe "as SuperAdmin" do
          before(:each) do
            login_as(:user_admin)
          end
          describe "in a private space" do
            before(:each) do
              @space = spaces(:private_no_roles)
              @user = users(:user_normal2)
            end
          
            it "should NOT let the user to UPDATE the profile of a user of this space" do
              put :update, :user_id => @user, :profile => @invalid_attributes
              response.should {render :template => "edit"}
            end
          end
        
          describe "in the public space" do
            before(:each) do
              @space = spaces(:public)
              @user = users(:user_normal2)
            end
          
            it "should NOT let the user to UPDATE the profile of a user of this space" do
              put :update, :user_id => @user, :profile => @invalid_attributes
              response.should {render :template => "edit"}
            end  
          end
    
        end
        describe "as normal_user" do
          before(:each) do
            login_as(:user_normal)
          end
          describe "in a private space where the user has the role Admin " do
            before(:each) do
              @space = spaces(:private_admin)
              @user = users(:user_normal2)
            end
          
            it "should NOT let the user to UPDATE the profile of a user of this space" do
              put :update , :user_id => @user, :profile => @invalid_attributes
              assert_response 403
            end
            
            it "should NOT let the user to UPDATE his profile" do
              put :update , :user_id => users(:user_normal), :profile => @invalid_attributes
              response.should {render :template => "edit"}
            end            
          
          end
        
          describe "in a private space where the user has the role User" do
            before(:each) do
              @space = spaces(:private_user)
              @user = users(:user_normal2)
            end
          
            it "should NOT let the user to UPDATE the profile of a user of this space" do
              put :update, :user_id => @user, :profile => @invalid_attributes
              assert_response 403
            end
            it "should NOT let the user to UPDATE his profile" do
              put :update , :user_id => users(:user_normal), :profile => @invalid_attributes
              response.should {render :template => "edit"}
            end             
          
          end
          describe "in a private space where the user has the role Invited " do
            before(:each) do
              @space = spaces(:private_invited)
              @user = users(:user_normal2)
            end
          
            it "should NOT let the user to UPDATE profile of a user of this space" do
              put :update, :user_id => @user, :profile => @invalid_attributes
              assert_response 403
            end
            it "should NOT let the user to UPDATE his profile" do
              put :update , :user_id => users(:user_normal), :profile => @invalid_attributes
              response.should {render :template => "edit"}
            end           
          end
        
          describe "in a private space where the user has not any roles" do
            before(:each) do
              @space = spaces(:private_no_roles)
              @user = users(:user_normal2)
            end
          
            it "should NOT let the user to UPDATE the profile of a user of this space" do
              put :update , :user_id => @user, :profile => @invalid_attributes
              assert_response 403
            end
            it "should NOT let the user to UPDATE his profile" do
              put :update , :user_id => users(:user_normal), :profile => @invalid_attributes
              response.should {render :template => "edit"}
            end             
          end
        
          describe "without space" do
            before(:each) do
              @user = users(:user_normal2)
            end
          
            it "should NOT let the user to UPDATE the profile of a user of this space" do
              put :update, :user_id => @user, :profile => @invalid_attributes
              assert_response 403
            end     
          end
        
        
          describe "in the public space" do
          
            before(:each) do
              @space = spaces(:public)
              @user = users(:user_normal2)
            end
          
            it "should NOT let the user to UPDATE the profile of a user of this space" do
              put :update, :user_id => @user, :profile => @invalid_attributes
              assert_response 403
            end
            it "should NOT let the user to UPDATE his profile" do
              put :update , :user_id => users(:user_normal), :profile => @invalid_attributes
              response.should {render :template => "edit"}
            end             
          end 
        end 
      end
    
      describe "if you are not logged in" do
        describe "in a private space" do
          before(:each) do
            @space = spaces(:private_no_roles)
            @user = users(:user_normal2)
          end
        
          it "should NOT let the user to UPDATE the profile of a user of this space" do
            put :update, :user_id => @user, :profile => @invalid_attributes
            assert_response 401
          end
        end
      
        describe "in the public space" do
          before(:each) do
            @space = spaces(:public)
            @user = users(:user_normal2)
          end
        
          it "should NOT let the user to UDATE the profile of a user of this space" do
            put :update,  :user_id => @user, :profile => @invalid_attributes
            assert_response 401
          end  
        end 
      end            
    end

  end

################################################

  describe "responding to DELETE destroy" do
    describe "when you are logged in" do
      describe "as SuperAdmin" do
        before(:each) do
          login_as(:user_admin)
        end
        describe "in a private space" do
          before(:each) do
            @space = spaces(:private_no_roles)
            @user = users(:user_normal2)
            session[:space_id] = @space.name
          end
          
          it "should let the user to DELETE the profile of a user of this space and redirect" do
            assert_difference 'Profile.count', -1 do
              delete :destroy, :user_id => @user
              response.should  redirect_to(space_user_profile_url(@space, @user))
            end
          end        
        end
        
        describe "in the public space" do
          before(:each) do
            @space = spaces(:public)
            @user = users(:user_normal2)
            session[:space_id] = @space.name
          end
          
          it "should let the user to DELETE the profile of a user of this space and redirect" do
            assert_difference 'Profile.count', -1 do
              delete :destroy, :user_id => @user.id
              response.should  redirect_to(space_user_profile_url(@space, @user))
            end
          end           
        end    
      end
      describe "as normal_user" do
        before(:each) do
          login_as(:user_normal)
        end
        describe "in a private space where the user has the role Admin " do
          before(:each) do
            @space = spaces(:private_admin)
            @user = users(:user_normal2)
            session[:space_id] = @space.name
          end
          
          it "should NOT let the user to DELETE the profile information of a user of this space" do
            assert_no_difference 'Profile.count' do
              delete :destroy , :user_id => @user
              assert_response 403
            end
          end
          it "should let the user to DELETE his own profile and redirect" do
            assert_difference 'Profile.count', -1 do
              delete :destroy , :user_id => users(:user_normal)
              response.should  redirect_to(space_user_profile_path(@space, users(:user_normal)))  
            end
          end              
          
        end
        
        describe "in a private space where the user has the role User" do
          before(:each) do
            @space = spaces(:private_user)
            @user = users(:user_normal2)
            session[:space_id] = @space.name
          end
          
          it "should NOT let the user to DELETE the profile of a user of this space" do
            assert_no_difference 'User.count' do
              delete :destroy, :user_id => @user
              assert_response 403
            end
          end
          
          it "should let the user to DELETE his own profile and redirect" do
            assert_difference 'Profile.count', -1 do
              delete :destroy , :user_id => users(:user_normal)
              response.should  redirect_to(space_user_profile_url(@space, users(:user_normal)))  
            end
          end              
                 
        end
        describe "in a private space where the user has the role Invited " do
          before(:each) do
            @space = spaces(:private_invited)
            @user = users(:user_normal2)
            session[:space_id] = @space.name
          end
          
          it "should NOT let the user to DELETE the profile of a user of this space" do
            assert_no_difference 'Profile.count' do
              delete :destroy, :user_id => @user
              assert_response 403
            end
          end
          it "should let the user to DELETE his own profile and redirect" do
            assert_difference 'Profile.count' , -1 do
              delete :destroy , :user_id => users(:user_normal)
              response.should  redirect_to(space_user_profile_url(@space,users(:user_normal)))  
            end
          end              
                 
        end
        
        describe "in a private space where the user has not any roles" do
          before(:each) do
            @space = spaces(:private_no_roles)
            @user = users(:user_normal2)
            session[:space_id] = @space.name
          end
          
          it "should NOT let the user to DELETE the profile of a user of this space" do
            assert_no_difference 'Profile.count' do
              delete :destroy , :user_id => @user.id
              assert_response 403
            end
          end
          it "should let the user to DELETE his own profile and redirect" do
            assert_difference 'Profile.count', -1 do
              delete :destroy , :user_id => users(:user_normal)
              response.should  redirect_to(space_user_profile_url(@space, users(:user_normal)))  
            end
          end              
                 
        end
        
        describe "without space" do
          before(:each) do
            @user = users(:user_normal2)
          end
          
          it "should NOT let the user to DELETE the profile of a user of this space" do
            assert_no_difference 'Profile.count' do
              delete :destroy, :user_id => @user
              assert_response 403
            end
          end
          it "should let the user to DELETE his own profile and redirect" do
            assert_difference 'Profile.count' , -1 do
              delete :destroy , :user_id => users(:user_normal)
              response.should  redirect_to(space_user_profile_url(@space, users(:user_normal)))  
            end
          end              
                 
        end
        
        
        describe "in the public space" do
          
          before(:each) do
            @space = spaces(:public)
            @user = users(:user_normal2)
            session[:space_id] = @space.name
          end
          
          it "should NOT let the user to DELETE the profile of a user of this space" do
            assert_no_difference 'Profile.count' do
              delete :destroy, :user_id => @user
              assert_response 403
            end
          end
          it "should let the user to DELETE his own profile and redirect" do
            assert_difference 'Profile.count', -1 do
              delete :destroy , :user_id => users(:user_normal)
              response.should  redirect_to(space_user_profile_url(@space, users(:user_normal)))  
            end
          end              
                 
        end
        describe "as a user without profile" do
          before(:each) do
            login_as(:user_normal3)
            @space = spaces(:private_no_roles)
            @user = users(:user_normal3)
            session[:space_id] = @space.name
          end
          it "should NOT let the user to DELETE his non existing profile" do
            assert_no_difference 'Profile.count' do
              delete :destroy, :user_id => @user.id
              response.should  redirect_to(space_user_profile_url(@space, @user))
            end
          end          
        end
      end 
    end
    
    describe "if you are not logged in" do
      describe "in a private space" do
        before(:each) do
          @space = spaces(:private_no_roles)
          @user = users(:user_normal2)
        end
        
        it "should NOT let the user to DELETE the profile of a user of this space" do
          assert_no_difference 'User.count' do
            delete :destroy, :user_id => @user.id
            assert_response 401
          end
        end
      end
      
      describe "in the public space" do
        before(:each) do
          @space = spaces(:public)
          @user = users(:user_normal2)
        end
        
        it "should NOT let the user to DELETE the profile of a user of this space" do
          assert_no_difference 'User.count' do
            delete :destroy,  :user_id => @user.id
            assert_response 401
          end
        end  
      end 
    end
  end

end
