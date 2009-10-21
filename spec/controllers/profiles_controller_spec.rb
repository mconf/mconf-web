require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ProfilesController do
  include ActionController::AuthenticationTestHelper
  
  integrate_views
  
  before(:all) do

  end
  
  after(:all) do 

  end

  describe "A Superadmin" do
    before(:each) do
      #the superuser
      @superuser = Factory(:superuser)
      #a private space and a user in that space
      @private_space = Factory(:private_space)
      @user = Factory(:user_performance, :stage => @private_space).agent
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
    it "should be able to edit his profile" do
      #first we create the user profile
      Factory(:profile, :user=>@superuser)
      valid_attributes = Factory.attributes_for(:profile)
      valid_attributes["user_attributes"] = {"id"=>@superuser.id, "login"=>@superuser.login, "email"=>"newemail@gmail.com"}
      put :update, :user_id => @superuser, :profile => valid_attributes              
      response.should redirect_to(user_profile_path(@superuser))
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

    it "should be able to see his public and private profiles with visibility :everybody" do
      #first we create the user profile
      Factory(:profile, :user=>@superuser)

      #we set the visibility to :everybody and try to see the profile
      @superuser.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:everybody))
      get :show , :user_id => @superuser.id
      assert_response 200
      response.should render_template("profiles/show.html.erb")
      response.should include_text(I18n.t('profile.public'))
      response.should include_text(I18n.t('profile.private'))
      
      #we restore the visibility to the default value
      @superuser.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
    end
    
    it "should be able to see his public and private profiles with visibility :nobody" do
      #first we create the user profile
      Factory(:profile, :user=>@superuser)

      #we set the visibility to :nobody and try to see the profile
      @superuser.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:nobody))
      get :show , :user_id => @superuser.id
      assert_response 200
      response.should render_template("profiles/show.html.erb")
      response.should include_text(I18n.t('profile.public'))
      response.should include_text(I18n.t('profile.private'))
      
      #we restore the visibility to the default value
      @superuser.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
    end
    
    it "should be able to see a user's public and private profiles with visibility :everybody" do
      #first we create the user profile
      Factory(:profile, :user=>@user)

      #we set the visibility to :everybody and try to see the profile
      @user.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:everybody))
      get :show , :user_id => @user.id
      assert_response 200
      response.should render_template("profiles/show.html.erb")
      response.should include_text(I18n.t('profile.public'))
      response.should include_text(I18n.t('profile.private'))
      
      #we restore the visibility to the default value
      @user.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
    end
    
    it "should be able to see a user's public and private profiles with visibility :nobody" do
      #first we create the user profile
      Factory(:profile, :user=>@user)

      #we set the visibility to :nobody and try to see the profile
      @user.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:nobody))
      get :show , :user_id => @user.id
      assert_response 200
      response.should render_template("profiles/show.html.erb")
      response.should include_text(I18n.t('profile.public'))
      response.should include_text(I18n.t('profile.private'))
      
      #we restore the visibility to the default value
      @user.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
    end

    after(:each) do
      @superuser.destroy
      @private_space.destroy
      @user.destroy
    end
  end

  describe "A logged user" do
    before(:each) do
      #a private space and three users in that space
      @private_space = Factory(:private_space)
      @admin = Factory(:admin_performance, :stage => @private_space).agent
      @user = Factory(:user_performance, :stage => @private_space).agent
      @invited = Factory(:invited_performance, :stage => @private_space).agent
      #a public space and two users in that space
      @public_space = Factory(:public_space)
      @user_public_1 = Factory(:user_performance, :stage => @public_space).agent
      @user_public_2 = Factory(:user_performance, :stage => @public_space).agent
    end
    
    it "should be able to get the new view for his profile" do
      login_as(@user)
      get :new, :user_id => @user.id
      assert_response 200
      response.should render_template("profiles/new.html.erb")
    end
    it "should be able to create his profile" do 
      login_as(@user)
      valid_attributes = Factory.attributes_for(:profile)
      valid_attributes["user_attributes"] = {"id"=>@user.id, "login"=>@user.login, "email"=>@user.email}
      assert_difference 'Profile.count' do
        post :create, :user_id => @user.id, :profile=> valid_attributes
        response.should redirect_to(user_profile_path(@user))
      end
    end
    it "should be able to get the edit view for his profile" do
      login_as(@user)
      #first we create the user profile
      Factory(:profile, :user=>@user)
      get :edit, :user_id => @user
      assert_response 200
      response.should render_template("profiles/edit.html.erb")
    end
    it "should be able to edit his profile" do 
      login_as(@user)
      #first we create the user profile
      Factory(:profile, :user=>@user)
      valid_attributes = Factory.attributes_for(:profile)
      valid_attributes["user_attributes"] = {"id"=>@user.id, "login"=>@user.login, "email"=>"newemail@gmail.com"}
      put :update, :user_id => @user, :profile => valid_attributes              
      response.should redirect_to(user_profile_path(@user))
    end
    it "should be able to delete his profile" do
      login_as(@user)
      Factory(:profile, :user=>@user)
      assert_difference 'Profile.count', -1 do
        delete :destroy, :user_id => @user
        flash[:notice].should == I18n.t('profile.deleted')
        response.should redirect_to(user_profile_path(@user))
      end
    end
    it "should NOT be able to get the new view for his profile if he has one" do
      login_as(@user)
      Factory(:profile, :user=>@user)
      get :new, :user_id => @user.id        
      flash[:error].should == I18n.t('profile.error.exist')
      response.should redirect_to(user_profile_path(@user))
    end
    it "should NOT be able to create his profile if he already has one" do
      login_as(@user)
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
    it "should NOT be able to get the new view for anyone's profile" do
      login_as(@user)
      get :new, :user_id => @user_public_1.id
      assert_response 403
    end

    it "should NOT be able to create anyone's profile" do 
      login_as(@user)
      valid_attributes = Factory.attributes_for(:profile)
      valid_attributes["user_attributes"] = {"id"=>@invited.id, "login"=>@invited.login, "email"=>@invited.email}
      assert_no_difference 'Profile.count' do
        post :create, :user_id => @invited.id, :profile=> valid_attributes
        assert_response 403
      end
    end
    it "should NOT be able to get the edit view for anyone's profile" do
      login_as(@user)
      get :edit, :user_id => @user_public_1.id
      assert_response 403
      get :edit, :user_id => @admin.id
      assert_response 403
    end
    it "shoud NOT be able to edit anyone's profile" do 
      login_as(@user)
      #first we create the user profile
      Factory(:profile, :user=>@invited)
      valid_attributes = Factory.attributes_for(:profile)
      valid_attributes["user_attributes"] = {"id"=>@invited.id, "login"=>@invited.login, "email"=>"newemail@gmail.com"}
      put :update, :user_id => @invited, :profile => valid_attributes              
      assert_response 403
    end
    it "should NOT be able to delete anyone's profile" do
      login_as(@user)
      Factory(:profile, :user=>@invited)
      assert_no_difference 'Profile.count' do
        delete :destroy, :user_id => @invited
        assert_response 403
      end
    end
    
    it "should be able to see his public and private profiles with visibility :everybody" do
      login_as(@user)
      #first we create the user profile
      Factory(:profile, :user=>@user)

      #we set the visibility to :everybody and try to see the profile
      @user.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:everybody))
      get :show , :user_id => @user.id
      assert_response 200
      response.should render_template("profiles/show.html.erb")
      response.should include_text(I18n.t('profile.public'))
      response.should include_text(I18n.t('profile.private'))
      
      #we restore the visibility to the default value
      @user.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
    end
    
    it "should be able to see his public and private profiles with visibility :nobody" do
      login_as(@user)
      #first we create the user profile
      Factory(:profile, :user=>@user)

      #we set the visibility to :nobody and try to see the profile
      @user.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:nobody))
      get :show , :user_id => @user.id
      assert_response 200
      response.should render_template("profiles/show.html.erb")
      response.should include_text(I18n.t('profile.public'))
      response.should include_text(I18n.t('profile.private'))
      
      #we restore the visibility to the default value
      @user.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
    end
    
    it "should be able to see a user's public and private profiles with visibility :everybody" do
      login_as(@user)
      #first we create the user profile
      Factory(:profile, :user=>@user_public_1)

      #we set the visibility to :everybody and try to see the profile
      @user_public_1.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:everybody))
      get :show , :user_id => @user_public_1.id
      assert_response 200
      response.should render_template("profiles/show.html.erb")
      response.should include_text(I18n.t('profile.public'))
      response.should include_text(I18n.t('profile.private'))
      
      #we restore the visibility to the default value
      @user_public_1.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
    end

    it "should be able to see a user's public and private profiles with visibility :members" do
      login_as(@user)
      #first we create the user profile
      Factory(:profile, :user=>@user_public_1)
      #we set the visibility to :members and try to see the profile
      @user_public_1.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:members))
      get :show , :user_id => @user_public_1.id
      assert_response 200
      response.should render_template("profiles/show.html.erb")
      response.should include_text(I18n.t('profile.public'))
      response.should include_text(I18n.t('profile.private'))
      
      #we restore the visibility to the default value
      @user_public_1.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
    end

    it ("should be able to see a user's public and private profiles with visibility :public_fellows " +
      "if the other user is in the same public or private space") do
      login_as(@user_public_1)
      #first we create the user profile
      Factory(:profile, :user=>@user_public_2)

      #we set the visibility to :public_fellows and try to see the profile
      @user_public_2.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
      get :show , :user_id => @user_public_2.id
      assert_response 200
      response.should render_template("profiles/show.html.erb")
      response.should include_text(I18n.t('profile.public'))
      response.should include_text(I18n.t('profile.private'))
      
      #we restore the visibility to the default value
      @user_public_2.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
    end
    
    it ("should be able to see ONLY a user's public profile (NOT the private profile) with visibility " +
      ":public_fellows if the other user is NOT in the same public or private space") do
      login_as(@user)
      #first we create the user profile
      Factory(:profile, :user=>@user_public_1)

      #we set the visibility to :public_fellows and try to see the profile
      @user_public_1.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
      get :show , :user_id => @user_public_1.id
      assert_response 200
      response.should render_template("profiles/show.html.erb")
      response.should include_text(I18n.t('profile.public'))
      response.should_not include_text(I18n.t('profile.private'))
      
      #we restore the visibility to the default value
      @user_public_1.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
    end
    
    it ("should be able to see a user's public and private profiles with visibility :private_fellows " +
      "if the other user is in the same PRIVATE space") do
      login_as(@user)
      #first we create the user profile
      Factory(:profile, :user=>@admin)

      #we set the visibility to :private_fellows and try to see the profile
      @admin.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:private_fellows))
      get :show , :user_id => @admin.id
      assert_response 200
      response.should render_template("profiles/show.html.erb")
      response.should include_text(I18n.t('profile.public'))
      response.should include_text(I18n.t('profile.private'))
      
      #we restore the visibility to the default value
      @admin.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
    end
    
    it ("should be able to see ONLY a user's public profile (NOT the private profile) with visibility " +
      ":private_fellows if the other user is NOT in the same PRIVATE space") do
      login_as(@user_public_1)

      #first we create the user profile
      Factory(:profile, :user=>@user_public_2)

      #we set the visibility to :private_fellows and try to see the profile
      @user_public_2.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:private_fellows))
      get :show , :user_id => @user_public_2.id
      assert_response 200
      response.should render_template("profiles/show.html.erb")
      response.should include_text(I18n.t('profile.public'))
      response.should_not include_text(I18n.t('profile.private'))
      
      #we restore the visibility to the default value
      @user_public_2.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
    end

    it "should be able to see ONLY a user's public profile (NOT the private profile) with visibility :nobody" do
      login_as(@user)
      #first we create the user profile
      Factory(:profile, :user=>@admin)

      #we set the visibility to :nobody and try to see the profile
      @admin.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:nobody))
      get :show , :user_id => @admin.id
      assert_response 200
      response.should render_template("profiles/show.html.erb")
      response.should include_text(I18n.t('profile.public'))
      response.should_not include_text(I18n.t('profile.private'))
      
      #we restore the visibility to the default value
      @admin.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
    end

    after(:each) do 
      #remove all the stuff created
      @private_space.destroy
      @admin.destroy
      @user.destroy
      @invited.destroy
      @public_space.destroy
      @user_public_1.destroy
      @user_public_2.destroy
    end

  end

  describe "The admin of a space" do
    before(:each) do
      #a private space and three users in that space
      @private_space = Factory(:private_space)
      @admin = Factory(:admin_performance, :stage => @private_space).agent
      @user = Factory(:user_performance, :stage => @private_space).agent
      @invited = Factory(:invited_performance, :stage => @private_space).agent
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
    
    #basic visibility tests because admin status will not affect visibility behaviour,
    #it has already been tested in the previous describe block
    
    it "should be able to see his public and private profiles with visibility :everybody" do
      #first we create the user profile
      Factory(:profile, :user=>@admin)

      #we set the visibility to :everybody and try to see the profile
      @admin.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:everybody))
      get :show , :user_id => @admin.id
      assert_response 200
      response.should render_template("profiles/show.html.erb")
      response.should include_text(I18n.t('profile.public'))
      response.should include_text(I18n.t('profile.private'))
      
      #we restore the visibility to the default value
      @admin.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
    end
    
    it "should be able to see his public and private profiles with visibility :nobody" do
      #first we create the user profile
      Factory(:profile, :user=>@admin)

      #we set the visibility to :nobody and try to see the profile
      @admin.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:nobody))
      get :show , :user_id => @admin.id
      assert_response 200
      response.should render_template("profiles/show.html.erb")
      response.should include_text(I18n.t('profile.public'))
      response.should include_text(I18n.t('profile.private'))
      
      #we restore the visibility to the default value
      @admin.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
    end
    
    it "should be able to see a user's public and private profiles with visibility :everybody" do
      #first we create the user profile
      Factory(:profile, :user=>@user)

      #we set the visibility to :everybody and try to see the profile
      @user.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:everybody))
      get :show , :user_id => @user.id
      assert_response 200
      response.should render_template("profiles/show.html.erb")
      response.should include_text(I18n.t('profile.public'))
      response.should include_text(I18n.t('profile.private'))
      
      #we restore the visibility to the default value
      @user.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
    end
    
    it "should be able to see ONLY a user's public profile (NOT the private profile) with visibility :nobody" do
      #first we create the user profile
      Factory(:profile, :user=>@user)

      #we set the visibility to :nobody and try to see the profile
      @user.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:nobody))
      get :show , :user_id => @user.id
      assert_response 200
      response.should render_template("profiles/show.html.erb")
      response.should include_text(I18n.t('profile.public'))
      response.should_not include_text(I18n.t('profile.private'))
      
      #we restore the visibility to the default value
      @user.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
    end
    
    after(:each) do 
      #remove all the stuff created
      @private_space.destroy
      @admin.destroy
      @user.destroy
      @invited.destroy
    end
    
  end

  describe "A not logged user" do       
    
    before(:each) do
      #a private space and two users in that space
      @private_space = Factory(:private_space)
      @user = Factory(:user_performance, :stage => @private_space).agent
      @invited = Factory(:invited_performance, :stage => @private_space).agent
    end    
    
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
  
    it "should be able to see a user's public and private profiles with visibility :everybody" do
      #first we create the user profile
      Factory(:profile, :user=>@invited)

      #we set the visibility to :everybody and try to see the profile
      @invited.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:everybody))
      get :show , :user_id => @invited.id
      assert_response 200
      response.should render_template("profiles/show.html.erb")
      response.should include_text(I18n.t('profile.public'))
      response.should include_text(I18n.t('profile.private'))
      
      #we restore the visibility to the default value
      @invited.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
    end

    it "should be able to see ONLY a user's public profile (NOT the private profile) with visibility :members" do
      #first we create the user profile
      Factory(:profile, :user=>@invited)

      #we set the visibility to :members and try to see the profile
      @invited.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:members))
      get :show , :user_id => @invited.id
      assert_response 200
      response.should render_template("profiles/show.html.erb")
      response.should include_text(I18n.t('profile.public'))
      response.should_not include_text(I18n.t('profile.private'))
      
      #we restore the visibility to the default value
      @invited.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
    end

    it "should be able to see ONLY a user's public profile (NOT the private profile) with visibility :public_fellows" do
      #first we create the user profile
      Factory(:profile, :user=>@invited)

      #we set the visibility to :public_fellows and try to see the profile
      @invited.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
      get :show , :user_id => @invited.id
      assert_response 200
      response.should render_template("profiles/show.html.erb")
      response.should include_text(I18n.t('profile.public'))
      response.should_not include_text(I18n.t('profile.private'))
      
      #we restore the visibility to the default value
      @invited.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
    end
    
    it "should be able to see ONLY a user's public profile (NOT the private profile) with visibility :private_fellows" do
      #first we create the user profile
      Factory(:profile, :user=>@invited)

      #we set the visibility to :private_fellows and try to see the profile
      @invited.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:private_fellows))
      get :show , :user_id => @invited.id
      assert_response 200
      response.should render_template("profiles/show.html.erb")
      response.should include_text(I18n.t('profile.public'))
      response.should_not include_text(I18n.t('profile.private'))
      
      #we restore the visibility to the default value
      @invited.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
    end

    it "should be able to see ONLY a user's public profile (NOT the private profile) with visibility :nobody" do
      #first we create the user profile
      Factory(:profile, :user=>@invited)

      #we set the visibility to :nobody and try to see the profile
      @invited.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:nobody))
      get :show , :user_id => @invited.id
      assert_response 200
      response.should render_template("profiles/show.html.erb")
      response.should include_text(I18n.t('profile.public'))
      response.should_not include_text(I18n.t('profile.private'))
      
      #we restore the visibility to the default value
      @invited.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
    end

    after(:each) do 
      #remove all the stuff created
      @private_space.destroy
      @user.destroy
      @invited.destroy
    end

  end

end
