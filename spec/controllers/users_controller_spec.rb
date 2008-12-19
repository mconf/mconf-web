require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')



describe UsersController do
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
    
    
  end
  
  ##########################
  
  describe "responding to GET new" do
    
    
  end
  
  
  ##########################
  describe "responding to GET edit" do
    
    
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
    
    
  end   
end
