require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ProfilesController do
  include ActionController::AuthenticationTestHelper
  
  integrate_views
  
  before(:all) do
    #the superuser
    @superuser = Factory(:superuser)
    #a private space and three users in that space
    @private_space = Factory(:private_space)
    @admin = Factory(:admin_performance, :stage => @private_space).agent
    @user = Factory(:user_performance, :stage => @private_space).agent
    @invited = Factory(:invited_performance, :stage => @private_space).agent
    #a public space
    @public_space = Factory(:public_space)
  end
  
  after(:all) do 
    #remove all the stuff created
    @superuser.destroy
    @private_space.destroy
    @admin.destroy
    @user.destroy
    @invited.destroy
    @public_space.destroy
  end
  

    
  describe "A Superadmin" do
    before(:each) do
      login_as(@superuser)
    end
    it "should be able to get the new view for his profile" do
      get :new, :user_id => @superuser.id
      assert_response 200
      response.should render_template("profiles/new.html.erb")
    end
    it "should be able to create his profile if he does not have one" do
      valid_attributes = Factory.attributes_for(:profile)
      valid_attributes["user_attributes"] = {"id"=>@superuser.id, "login"=>@superuser.login, "email"=>@superuser.email}
      assert_difference 'Profile.count' do
        post :create, :user_id => @superuser.id, :profile=> valid_attributes
        response.should redirect_to(user_profile_path(@superuser))
      end
    end 
    it "should NOT be able to get the new view for his profile if he already has one" do
      Factory(:profile, :user=>@superuser)
      get :new, :user_id => @superuser.id          
      flash[:error].should == I18n.t('profile.error.exist')
      response.should redirect_to(user_profile_path(@superuser))
    end
    it "should NOT be able to create his profile if he already has one" do
      valid_attributes = Factory.attributes_for(:profile)
      valid_attributes["user_attributes"] = {"id"=>@superuser.id, "login"=>@superuser.login, "email"=>@superuser.email}
      #we create the user profile first
      Factory(:profile, :user=>@superuser)
      assert_no_difference 'Profile.count' do
        post :create, :user_id => @superuser.id, :profile=> valid_attributes
        flash[:error].should == I18n.t('profile.error.exist')
        response.should redirect_to(user_profile_path(@superuser))
      end
    end 
    it "should be able to see his own profile" do
      get :show , :user_id => @superuser.id
      assert_response 200
      response.should render_template("profiles/show.html.erb")
    end
    it "should be able to delete his profile" do
      Factory(:profile, :user=>@superuser)
      assert_difference 'Profile.count', -1 do
        delete :destroy, :user_id => @superuser
        flash[:notice].should == I18n.t('profile.deleted')
        response.should redirect_to(user_profile_path(@superuser))
      end
    end
    it "should be able to get the edit view for his profile" do
      #first we create the user profile
      Factory(:profile, :user=>@superuser)
      get :edit, :user_id => @superuser
      assert_response 200
      response.should render_template("profiles/edit.html.erb")
    end
    it "shoud be able to edit his profile" do
      #first we create the user profile
      Factory(:profile, :user=>@superuser)
      valid_attributes = Factory.attributes_for(:profile)
      valid_attributes["user_attributes"] = {"id"=>@superuser.id, "login"=>@superuser.login, "email"=>"newemail@gmail.com"}
      put :update, :user_id => @superuser, :profile => valid_attributes              
      response.should redirect_to(user_profile_path(@superuser))
    end
    it "should be able to see any user's profile" do
      get :show , :user_id => @user.id
      assert_response 200
      response.should render_template("profiles/show.html.erb")
    end
    it "should be able to get the edit view for any user's profile" do 
      Factory(:profile, :user=>@user)
      get :edit, :user_id => @user
      assert_response 200
      response.should render_template("profiles/edit.html.erb")
    end
    it "should be able to edit any user's profile" do
      #first we create the user profile
      Factory(:profile, :user=>@user)
      valid_attributes = Factory.attributes_for(:profile)
      valid_attributes["user_attributes"] = {"id"=>@user.id, "login"=>@user.login, "email"=>"newemail@gmail.com"}
      put :update, :user_id => @user, :profile => valid_attributes              
      response.should redirect_to(user_profile_path(@user))
    end
    it "should be able to delete any user's profile" do 
      #first we create the user profile
      Factory(:profile, :user=>@user)
      assert_difference 'Profile.count', -1 do
        delete :destroy, :user_id => @user
        flash[:notice].should == I18n.t('profile.deleted')
        response.should redirect_to(user_profile_path(@user))
      end
    end
  end
  
  describe "A logged user" do
    before(:each) do
      login_as(@user)
    end
    it "should be able to get the new view for his profile" do
      get :new, :user_id => @user.id
      assert_response 200
      response.should render_template("profiles/new.html.erb")
    end
    it "should be able to create his profile" do 
      valid_attributes = Factory.attributes_for(:profile)
      valid_attributes["user_attributes"] = {"id"=>@user.id, "login"=>@user.login, "email"=>@user.email}
      assert_difference 'Profile.count' do
        post :create, :user_id => @user.id, :profile=> valid_attributes
        response.should redirect_to(user_profile_path(@user))
      end
    end
    it "should be able to see his profile" do 
      get :show, :user_id => @user.id
      assert_response 200
      response.should render_template("profiles/show.html.erb")
    end
    it "should be able to get the edit view for his profile" do
      #first we create the user profile
      Factory(:profile, :user=>@user)
      get :edit, :user_id => @user
      assert_response 200
      response.should render_template("profiles/edit.html.erb")
    end
    it "should be able to edit his profile" do 
      #first we create the user profile
      Factory(:profile, :user=>@user)
      valid_attributes = Factory.attributes_for(:profile)
      valid_attributes["user_attributes"] = {"id"=>@user.id, "login"=>@user.login, "email"=>"newemail@gmail.com"}
      put :update, :user_id => @user, :profile => valid_attributes              
      response.should redirect_to(user_profile_path(@user))
    end
    it "should be able to delete his profile" do
      Factory(:profile, :user=>@user)
      assert_difference 'Profile.count', -1 do
        delete :destroy, :user_id => @user
        flash[:notice].should == I18n.t('profile.deleted')
        response.should redirect_to(user_profile_path(@user))
      end
    end
    it "should be able to see any user's profile in his space" do 
      get :show , :user_id => @admin.id
      assert_response 200
      response.should render_template("profiles/show.html.erb")
    end
    it "should NOT be able to get the new view for his profile if he has one" do
      Factory(:profile, :user=>@user)
      get :new, :user_id => @user.id        
      flash[:error].should == I18n.t('profile.error.exist')
      response.should redirect_to(user_profile_path(@user))
    end
    it "should NOT be able to create his profile if he already has one" do
      valid_attributes = Factory.attributes_for(:profile)
      valid_attributes["user_attributes"] = {"id"=>@user.id, "login"=>@user.login, "email"=>@user.email}
      #we create the user profile first
      Factory(:profile, :user=>@user)
      assert_no_difference 'Profile.count' do
        post :create, :user_id => @user.id, :profile=> valid_attributes
        flash[:error].should == I18n.t('profile.error.exist')
        response.should redirect_to(user_profile_path(@user))
      end
    end
    it "should NOT be able to see any user's profile outside his spaces" do 
      get :show, :user_id => @superuser.id
      assert_response 403
    end
    it "should NOT be able to get the new view for anyone's profile" do
      get :new, :user_id => @superuser.id
      assert_response 403
    end
    it "should NOT be able to create anyone's profile" do 
      valid_attributes = Factory.attributes_for(:profile)
      valid_attributes["user_attributes"] = {"id"=>@invited.id, "login"=>@invited.login, "email"=>@invited.email}
      assert_no_difference 'Profile.count' do
        post :create, :user_id => @invited.id, :profile=> valid_attributes
        assert_response 403
      end
    end
    it "should NOT be able to get the edit view for anyone's profile" do
      get :edit, :user_id => @superuser.id
      assert_response 403
      get :edit, :user_id => @admin.id
      assert_response 403
    end
    it "shoud NOT be able to edit anyone's profile" do 
      #first we create the user profile
      Factory(:profile, :user=>@invited)
      valid_attributes = Factory.attributes_for(:profile)
      valid_attributes["user_attributes"] = {"id"=>@invited.id, "login"=>@invited.login, "email"=>"newemail@gmail.com"}
      put :update, :user_id => @invited, :profile => valid_attributes              
      assert_response 403
    end
    it "should NOT be able to delete anyone's profile" do
      Factory(:profile, :user=>@invited)
      assert_no_difference 'Profile.count' do
        delete :destroy, :user_id => @invited
        assert_response 403
      end
    end
  end
     
  describe "The admin of a space" do
    before(:each) do
      login_as(@admin)
    end        
    it "should NOT be able to get the new view for anyone's profile" do
      get :new, :user_id => @invited.id
      assert_response 403
    end
    it "should NOT be able to create anyone's profile" do 
      valid_attributes = Factory.attributes_for(:profile)
      valid_attributes["user_attributes"] = {"id"=>@invited.id, "login"=>@invited.login, "email"=>@invited.email}
      assert_no_difference 'Profile.count' do
        post :create, :user_id => @invited.id, :profile=> valid_attributes
        assert_response 403
      end
    end
    it "should NOT be able to get the edit view for anyone's profile" do
      get :edit, :user_id => @invited.id
      assert_response 403
      get :edit, :user_id => @user.id
      assert_response 403
    end
    it "shoud NOT be able to edit anyone's profile" do 
      #first we create the user profile
      Factory(:profile, :user=>@invited)
      valid_attributes = Factory.attributes_for(:profile)
      valid_attributes["user_attributes"] = {"id"=>@invited.id, "login"=>@invited.login, "email"=>"newemail@gmail.com"}
      put :update, :user_id => @invited, :profile => valid_attributes              
      assert_response 403
    end
    it "should NOT be able to delete anyone's profile" do
      Factory(:profile, :user=>@invited)
      assert_no_difference 'Profile.count' do
        delete :destroy, :user_id => @invited
        assert_response 403
      end
    end
  end

  
  describe "A not logged user" do       
    it "should NOT be able to get the new view for anyone's profile" do
      get :new, :user_id => @invited.id
      assert_response 401
    end
    it "should NOT be able to create anyone's profile" do 
      valid_attributes = Factory.attributes_for(:profile)
      valid_attributes["user_attributes"] = {"id"=>@invited.id, "login"=>@invited.login, "email"=>@invited.email}
      assert_no_difference 'Profile.count' do
        post :create, :user_id => @invited.id, :profile=> valid_attributes
        assert_response 401
      end
    end
    it "should NOT be able to get the edit view for anyone's profile" do
      get :edit, :user_id => @invited.id
      assert_response 401
      get :edit, :user_id => @user.id
      assert_response 401
    end
    it "shoud NOT be able to edit anyone's profile" do 
      #first we create the user profile
      Factory(:profile, :user=>@invited)
      valid_attributes = Factory.attributes_for(:profile)
      valid_attributes["user_attributes"] = {"id"=>@invited.id, "login"=>@invited.login, "email"=>"newemail@gmail.com"}
      put :update, :user_id => @invited, :profile => valid_attributes              
      assert_response 401
    end
    it "should NOT be able to delete anyone's profile" do
      Factory(:profile, :user=>@invited)
      assert_no_difference 'Profile.count' do
        delete :destroy, :user_id => @invited
        assert_response 401
      end
    end
  end
  

end
