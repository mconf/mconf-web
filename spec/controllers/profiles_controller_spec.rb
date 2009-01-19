require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ProfilesController do
  integrate_views
  include CMS::AuthenticationTestHelper
  fixtures :users , :spaces
  
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
            response.should render_template("show")
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
          
          it "should let the user to see the user's profile of a user of this space" do
            get :show , :user_id => @user.id
            assert_response 200
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
            @user = users(:user_normal2)
          end
          
          it "should NOT let the user to see the user's profile of a user of this space" do
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
          @user = users(:user_normal2)
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

  describe "responding to GET new" do
  
    it "should expose a new profile as @profile" do
      pending
      Profile.should_receive(:new).and_return(mock_profile)
      get :new
      assigns[:profile].should equal(mock_profile)
    end

  end

  describe "responding to GET edit" do
  
    it "should expose the requested profile as @profile" do
      pending
      Profile.should_receive(:find).with("37").and_return(mock_profile)
      get :edit, :id => "37"
      assigns[:profile].should equal(mock_profile)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do
      
      it "should expose a newly created profile as @profile" do
        pending
        Profile.should_receive(:new).with({'these' => 'params'}).and_return(mock_profile(:save => true))
        post :create, :profile => {:these => 'params'}
        assigns(:profile).should equal(mock_profile)
      end

      it "should redirect to the created profile" do
        pending
        Profile.stub!(:new).and_return(mock_profile(:save => true))
        post :create, :profile => {}
        response.should redirect_to(profile_url(mock_profile))
      end
      
    end
    
    describe "with invalid params" do

      it "should expose a newly created but unsaved profile as @profile" do
        pending
        Profile.stub!(:new).with({'these' => 'params'}).and_return(mock_profile(:save => false))
        post :create, :profile => {:these => 'params'}
        assigns(:profile).should equal(mock_profile)
      end

      it "should re-render the 'new' template" do
        pending
        Profile.stub!(:new).and_return(mock_profile(:save => false))
        post :create, :profile => {}
        response.should render_template('new')
      end
      
    end
    
  end

  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested profile" do
        pending
        Profile.should_receive(:find).with("37").and_return(mock_profile)
        mock_profile.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :profile => {:these => 'params'}
      end

      it "should expose the requested profile as @profile" do
        pending
        Profile.stub!(:find).and_return(mock_profile(:update_attributes => true))
        put :update, :id => "1"
        assigns(:profile).should equal(mock_profile)
      end

      it "should redirect to the profile" do
        pending
        Profile.stub!(:find).and_return(mock_profile(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(profile_url(mock_profile))
      end

    end
    
    describe "with invalid params" do

      it "should update the requested profile" do
        pending
        Profile.should_receive(:find).with("37").and_return(mock_profile)
        mock_profile.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :profile => {:these => 'params'}
      end

      it "should expose the profile as @profile" do
        pending
        Profile.stub!(:find).and_return(mock_profile(:update_attributes => false))
        put :update, :id => "1"
        assigns(:profile).should equal(mock_profile)
      end

      it "should re-render the 'edit' template" do
        pending
        Profile.stub!(:find).and_return(mock_profile(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do

    it "should destroy the requested profile" do
      pending
      Profile.should_receive(:find).with("37").and_return(mock_profile)
      mock_profile.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "should redirect to the profiles list" do
      pending
      Profile.stub!(:find).and_return(mock_profile(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(profiles_url)
    end

  end

end
