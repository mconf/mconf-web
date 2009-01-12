require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')



describe UsersController do
  integrate_views
  include CMS::AuthenticationTestHelper
  fixtures :users , :spaces
  
  
  
  def mock_user(stubs={})
    @mock_user ||= mock_model(user, stubs)
  end
  
  
  describe "responding to GET index" do
    
    describe " when you are logged in" do
      
      describe " as SuperAdmin" do
        
        before(:each) do
          login_as(:user_admin)
        end
        
        describe "in a private space" do
          
          before(:each) do
            @space = spaces(:private_no_roles)
          end
          
          it "should let the Super Admin to see the users" do
            get :index , :space_id => @space.name
            assert_response 200
          end         
        end
        
        describe "in the public space" do
          
          before(:each) do
            @space = spaces(:public)
          end
          
          it "should let the Super Admin to see the users" do
            get :index , :space_id => @space.name
            assert_response 200            
          end
        end
      end
      
      describe " as a normal user" do
        
        before(:each) do
          login_as(:user_normal)
        end
        describe "in a private space" do
          
          describe " where the user has the role Admin" do
            
            before(:each) do
              @space = spaces(:private_admin)  
            end
            
            it "should let the user to see the users" do
              get :index , :space_id => @space.name
              assert_response 200
            end
          end
          
          describe " where the user has the role User" do
            
            before(:each) do
              @space = spaces(:private_user)  
            end
            
            it "should let the user to see the users" do
              get :index , :space_id => @space.name
              assert_response 200
            end
          end
          
          describe " where the user has the role Invited" do
            before(:each) do
              @space = spaces(:private_invited)  
            end
            
            it "should let the user to see the users" do
              get :index , :space_id => @space.name
              assert_response 200
            end
          end
          
          describe " where the user has no roles" do
            before(:each) do
              @space = spaces(:private_no_roles)  
            end
            
            it "should NOT let the user to see the users" do
              get :index , :space_id => @space.name
              assert_response 403
            end
          end
        end
        
        describe "in the public space" do
          before(:each) do
            @space = spaces(:public)  
          end
          
          it "should let the user to see the users" do
            get :index , :space_id => @space.name
            assert_response 200
          end
        end
      end
    end
    
    describe " If you are not logged in" do
      describe "in a private space" do
        before(:each) do
          @space = spaces(:private_no_roles)
        end
        it "should NOT let the user to see the users" do
          get :index , :space_id => @space.name
          assert_response 403
        end
      end
      describe "in the public space" do
        before(:each) do
          @space = spaces(:public)
        end
        it "should let the user to see the users " do
          get :index , :space_id => @space.name
          assert_response 200
        end
      end
    end
  end
  
  #####################
  
  
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
          
          it "should let the user to see the account information of a user of this space" do
            get :show, :id => @user.id
            assert_response 200
          end
          
          it "should redirect to the associated user view" do
            get :show , :id => @user.id
            response.should render_template("show")
          end
          
        end
        
        describe "in the public space" do
          before(:each) do
            @space = spaces(:public)
            @user = users(:user_normal2)
          end
          
          it "should let the user to see the account information of a user of this space" do
            get :show, :id => @user.id
            assert_response 200
          end
          
          it "should redirect to the associated user view" do
            get :show, :id => @user.id
            response.should render_template("show")
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
          
          it "should not let the user to see the account information of a user of this space" do
            get :show , :id => @user.id
            assert_response 403
          end
          
        end
        
        describe "in a private space where the user has the role User" do
          before(:each) do
            @space = spaces(:private_user)
            @user = users(:user_normal2)
          end
          
          it "should not let the user to see the account information of a user of this space" do
            get :show, :id => @user.id
            assert_response 403
          end
          
        end
        describe "in a private space where the user has the role Invited " do
          before(:each) do
            @space = spaces(:private_invited)
            @user = users(:user_normal2)
          end
          
          it "should not let the user to see the account information of a user of this space" do
            get :show, :id => @user.id
            assert_response 403
          end
          
        end
        
        describe "in a private space where the user has not any roles" do
          before(:each) do
            @space = spaces(:private_no_roles)
            @user = users(:user_normal2)
          end
          
          it "should NOT let the user to see the account information of a user of this space" do
            get :show , :id => @user.id
            assert_response 403
          end       
        end
        
        describe "without space" do
          before(:each) do
            @user = users(:user_normal2)
          end
          
          it "should NOT let the user to see the account information of a user of this space" do
            get :show, :id => @user.id
            assert_response 403
          end     
        end
        
        
        describe "in the public space" do
          
          before(:each) do
            @space = spaces(:public)
            @user = users(:user_normal2)
          end
          
          it "should NOT let the user to see the account information of a user of this space" do
            get :show, :id => @user.id
            assert_response 403
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
        
        it "should NOT let the user to see the account information of a user of this space" do
          get :show, :id => @user.id
          assert_response 403
        end
      end
      
      describe "in the public space" do
        before(:each) do
          @space = spaces(:public)
          @user = users(:user_normal2)
        end
        
        it "should NOT let the user to see the account information of a user of this space" do
          get :show,  :id => @user.id
          assert_response 403
        end  
      end 
    end   
  end
  
  ##########################
  
  describe "responding to GET new" do
    describe "when you are logged in" do
      describe "as super Admin" do
        before(:each)do
          login_as(:user_admin)
        end
        
        it "should let the user to create a new account" do
          get :new
          assert_response 200
        end    
      end
      
      describe "as a normal user" do
        before(:each)do
          login_as(:user_normal)
        end
        
        it "should let the user to create a new account" do
          get :new
          assert_response 200
        end
        
      end
    end
    describe "if you are not logged in" do
      it "should let the user to create a new account" do
        get :new
        assert_response 200
      end
    end
  end
  
  
  ##########################
  describe "responding to GET edit" do
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
          
          it "should let the user to edit the account information of a user of this space" do
            get :edit, :id => @user.id
            assert_response 200
          end
          
          it "should redirect to the associated user view" do
            get :edit , :id => @user.id
            response.should render_template("edit")
          end
          
        end
        
        describe "in the public space" do
          before(:each) do
            @space = spaces(:public)
            @user = users(:user_normal2)
          end
          
          it "should let the user to edit the account information of a user of this space" do
            get :edit, :id => @user.id
            assert_response 200
          end
          
          it "should redirect to the associated user view" do
            get :edit, :id => @user.id
            response.should render_template("edit")
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
          
          it "should not let the user to edit the account information of a user of this space" do
            get :edit , :id => @user.id
            assert_response 403
          end
          
        end
        
        describe "in a private space where the user has the role User" do
          before(:each) do
            @space = spaces(:private_user)
            @user = users(:user_normal2)
          end
          
          it "should not let the user to edit the account information of a user of this space" do
            get :edit, :id => @user.id
            assert_response 403
          end
          
        end
        describe "in a private space where the user has the role Invited " do
          before(:each) do
            @space = spaces(:private_invited)
            @user = users(:user_normal2)
          end
          
          it "should not let the user to edit the account information of a user of this space" do
            get :edit, :id => @user.id
            assert_response 403
          end
          
        end
        
        describe "in a private space where the user has not any roles" do
          before(:each) do
            @space = spaces(:private_no_roles)
            @user = users(:user_normal2)
          end
          
          it "should NOT let the user to edit the account information of a user of this space" do
            get :edit , :id => @user.id
            assert_response 403
          end       
        end
        
        describe "without space" do
          before(:each) do
            @user = users(:user_normal2)
          end
          
          it "should NOT let the user to edit the account information of a user of this space" do
            get :edit, :id => @user.id
            assert_response 403
          end     
        end
        
        
        describe "in the public space" do
          
          before(:each) do
            @space = spaces(:public)
            @user = users(:user_normal2)
          end
          
          it "should NOT let the user to edit the account information of a user of this space" do
            get :edit, :id => @user.id
            assert_response 403
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
        
        it "should NOT let the user to edit the account information of a user of this space" do
          get :edit, :id => @user.id
          assert_response 401
        end
      end
      
      describe "in the public space" do
        before(:each) do
          @space = spaces(:public)
          @user = users(:user_normal2)
        end
        
        it "should NOT let the user to edit the account information of a user of this space" do
          get :edit,  :id => @user.id
           assert_response 401
        end  
      end 
    end            
  end
  
  #################
  
  describe "responding to POST create" do
    
    describe "with valid params" do
      
      
    end
    
    describe "with invalid params" do
      
      
      
    end
  end
  
  
  ####################
  
  describe "responding to PUT udpate" do
    
    describe "with valid params" do
      
      
    end
    
    describe "with invalid params" do
      
    end
  end
  
  ##################################
  
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
          end
          
          it "should let the user to DELETE the account information of a user of this space" do
            assert_difference 'User.count'do
              delete :destroy, :id => @user.id
              assert_response 200
            end
          end
          
          it "should redirect to the space's users list" do
            delete :destroy , :id => @user.id
            response.should redirect_to(space_users_path(@space)) 
          end
          
        end
        
        describe "in the public space" do
          before(:each) do
            @space = spaces(:public)
            @user = users(:user_normal2)
          end
          
          it "should let the user to DELETE the account information of a user of this space" do
            assert_difference 'User.count' do
              delete :destroy, :id => @user.id
              assert_response 200
            end
          end
          
          it "should redirect to the space's users list" do
            delete :destroy, :id => @user.id
            response.should redirect_to(space_users_path(@space)) 
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
          
          it "should NOT let the user to DELETE the account information of a user of this space" do
            assert_no_difference 'User.count' do
              delete :destroy , :id => @user.id
              assert_response 403
            end
          end          
        end
        
        describe "in a private space where the user has the role User" do
          before(:each) do
            @space = spaces(:private_user)
            @user = users(:user_normal2)
          end
          
          it "should NOT let the user to DELETE the account information of a user of this space" do
            assert_no_difference 'User.count' do
              delete :destroy, :id => @user.id
              assert_response 403
            end
          end
          
        end
        describe "in a private space where the user has the role Invited " do
          before(:each) do
            @space = spaces(:private_invited)
            @user = users(:user_normal2)
          end
          
          it "should NOT let the user to DELETE the account information of a user of this space" do
            assert_no_difference 'User.count' do
              delete :destroy, :id => @user.id
              assert_response 403
            end
          end
          
        end
        
        describe "in a private space where the user has not any roles" do
          before(:each) do
            @space = spaces(:private_no_roles)
            @user = users(:user_normal2)
          end
          
          it "should NOT let the user to DELETE the account information of a user of this space" do
            assert_no_difference 'User.count' do
              delete :destroy , :id => @user.id
              assert_response 403
            end
          end       
        end
        
        describe "without space" do
          before(:each) do
            @user = users(:user_normal2)
          end
          
          it "should NOT let the user to DELETE the account information of a user of this space" do
            assert_no_difference 'User.count' do
              delete :destroy, :id => @user.id
              assert_response 403
            end
          end     
        end
        
        
        describe "in the public space" do
          
          before(:each) do
            @space = spaces(:public)
            @user = users(:user_normal2)
          end
          
          it "should NOT let the user to DELETE the account information of a user of this space" do
            assert_no_difference 'User.count' do
              delete :destroy, :id => @user.id
              assert_response 403
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
        
        it "should NOT let the user to DELETE the account information of a user of this space" do
          assert_no_difference 'User.count' do
            delete :destroy, :id => @user.id
            assert_response 401
          end
        end
      end
      
      describe "in the public space" do
        before(:each) do
          @space = spaces(:public)
          @user = users(:user_normal2)
        end
        
        it "should NOT let the user to DELETE the account information of a user of this space" do
          assert_no_difference 'User.count' do
            delete :destroy,  :id => @user.id
            assert_response 401
          end
        end  
      end 
    end         
  end   
end
