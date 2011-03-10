require "spec_helper"

describe ProfilesController do
  include ActionController::AuthenticationTestHelper
  
  render_views
  
  describe "A Superadmin" do
    before(:each) do
      #the superuser
      @superuser = Factory(:superuser)
      #a private space and a user in that space
      @private_space = Factory(:private_space)
      @user = Factory(:user_performance, :stage => @private_space).agent
      login_as(@superuser)
    end

    it "should be able to delete his profile" do
      @superuser.profile.update_attributes Factory.attributes_for(:profile)
      expect {
        delete :destroy, :user_id => @superuser.to_param
        flash[:notice].should == I18n.t('profile.deleted')
        response.should redirect_to(user_path(@superuser))
      }.to change{ Profile.count }.by(-1)
    end
    it "should be able to get the edit view for his profile" do
      #first we fill the user profile
      @superuser.profile.update_attributes Factory.attributes_for(:profile)
      get :edit, :user_id => @superuser.to_param
      assert_response 200
      response.should render_template("profiles/edit")
    end
    it "should be able to edit his profile" do
      #first we fill the user profile
      @superuser.profile.update_attributes Factory.attributes_for(:profile)
      valid_attributes = Factory.attributes_for(:profile)
      valid_attributes["user_attributes"] = {"id"=>@superuser.id, "login"=>@superuser.login, "email"=>"newemail@gmail.com"}
      put :update, :user_id => @superuser.to_param, :profile => valid_attributes              
      response.should redirect_to(user_path(@superuser))
    end
    it "should be able to get the edit view for any user's profile" do 
      @user.profile.update_attributes Factory.attributes_for(:profile)
      get :edit, :user_id => @user.to_param
      assert_response 200
      response.should render_template("profiles/edit")
    end
    it "should be able to edit any user's profile" do
      #first we fill the user profile
      @user.profile.update_attributes Factory.attributes_for(:profile)
      valid_attributes = Factory.attributes_for(:profile)
      valid_attributes["user_attributes"] = {"id"=>@user.id, "login"=>@user.login, "email"=>"newemail@gmail.com"}
      put :update, :user_id => @user.to_param, :profile => valid_attributes              
      response.should redirect_to(user_path(@user))
    end
    it "should be able to delete any user's profile" do 
      #first we fill the user profile
      @user.profile.update_attributes Factory.attributes_for(:profile)
      expect {
        delete :destroy, :user_id => @user.to_param
        flash[:notice].should == I18n.t('profile.deleted')
        response.should redirect_to(user_path(@user))
      }.to change{ Profile.count }.by(-1)
    end

    it "should be able to see his public and private profiles with visibility :everybody" do
      #first we fill the user profile
      @superuser.profile.update_attributes Factory.attributes_for(:profile)
      #we set the visibility to :everybody and try to see the profile
      @superuser.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:everybody))
      get :show , :user_id => @superuser.to_param
      pending "Redo after redirect to user show"
      assert_response 200
      response.should render_template("users/show")
      response.should include(@superuser.full_name)
      response.should include(@superuser.email)
      
      #we restore the visibility to the default value
      @superuser.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
    end
    
    it "should be able to see his public and private profiles with visibility :nobody" do
      #first we fill the user profile
      @superuser.profile.update_attributes Factory.attributes_for(:profile)

      #we set the visibility to :nobody and try to see the profile
      @superuser.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:nobody))
      get :show , :user_id => @superuser.to_param
      pending "Redo after redirect to user show"
      assert_response 200
      response.should render_template("profiles/show")
      response.should include(@superuser.full_name)
      response.should include(@superuser.email)
      
      #we restore the visibility to the default value
      @superuser.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
    end
    
    it "should be able to see a user's public and private profiles with visibility :everybody" do
      #first we fill the user profile
      @user.profile.update_attributes Factory.attributes_for(:profile)

      #we set the visibility to :everybody and try to see the profile
      @user.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:everybody))
      get :show , :user_id => @user.to_param
      pending "Redo after redirect to user show"
      assert_response 200
      response.should render_template("profiles/show")
      response.should include(@user.full_name)
      response.should include(@user.email)
      
      #we restore the visibility to the default value
      @user.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
    end
    
    it "should be able to see a user's public and private profiles with visibility :nobody" do
      #first we fill the user profile
      @user.profile.update_attributes Factory.attributes_for(:profile)

      #we set the visibility to :nobody and try to see the profile
      @user.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:nobody))
      get :show , :user_id => @user.to_param
      pending "Redo after redirect to user show"
      assert_response 200
      response.should render_template("profiles/show")
      response.should include(@user.full_name)
      response.should include(@user.email)
      
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
    
    it "should be able to get the edit view for his profile" do
      login_as(@user)
      #first we fill the user profile
      @user.profile.update_attributes Factory.attributes_for(:profile)
      get :edit, :user_id => @user.to_param
      assert_response 200
      response.should render_template("profiles/edit")
    end
    it "should be able to edit his profile" do 
      login_as(@user)
      #first we fill the user profile
      @user.profile.update_attributes Factory.attributes_for(:profile)
      valid_attributes = Factory.attributes_for(:profile)
      valid_attributes["user_attributes"] = {"id"=>@user.id, "login"=>@user.login, "email"=>"newemail@gmail.com"}
      put :update, :user_id => @user.to_param, :profile => valid_attributes              
      response.should redirect_to(user_path(@user))
    end
    it "should be able to delete his profile" do
      login_as(@user)
      @user.profile.update_attributes Factory.attributes_for(:profile)
      expect {
        delete :destroy, :user_id => @user.to_param
        flash[:notice].should == I18n.t('profile.deleted')
        response.should redirect_to(user_path(@user))
      }.to change{ Profile.count }.by(-1)
    end

    it "should NOT be able to get the edit view for anyone's profile" do
      login_as(@user)
      get :edit, :user_id => @user_public_1.to_param
      assert_response 403
      get :edit, :user_id => @admin.to_param
      assert_response 403
    end
    it "shoud NOT be able to edit anyone's profile" do 
      login_as(@user)
      #first we fill the user profile
      @invited.profile.update_attributes Factory.attributes_for(:profile)
      valid_attributes = Factory.attributes_for(:profile)
      valid_attributes["user_attributes"] = {"id"=>@invited.id, "login"=>@invited.login, "email"=>"newemail@gmail.com"}
      put :update, :user_id => @invited.to_param, :profile => valid_attributes              
      assert_response 403
    end
    it "should NOT be able to delete anyone's profile" do
      login_as(@user)
      @invited.profile.update_attributes Factory.attributes_for(:profile)
      expect {
        delete :destroy, :user_id => @invited.to_param
        assert_response 403
      }.not_to change{ Profile.count }
    end
    
    it "should be able to see his public and private profiles with visibility :everybody" do
      login_as(@user)
      #first we fill the user profile
      @user.profile.update_attributes Factory.attributes_for(:profile)

      #we set the visibility to :everybody and try to see the profile
      @user.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:everybody))
      get :show , :user_id => @user.to_param
      pending "Redo after redirect to user show"
      assert_response 200
      response.should render_template("profiles/show")
      response.should include(@user.full_name)
      response.should include(@user.email)
      
      #we restore the visibility to the default value
      @user.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
    end
    
    it "should be able to see his public and private profiles with visibility :nobody" do
      login_as(@user)
      #first we fill the user profile
      @user.profile.update_attributes Factory.attributes_for(:profile)

      #we set the visibility to :nobody and try to see the profile
      @user.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:nobody))
      get :show , :user_id => @user.to_param
      pending "Redo after redirect to user show"
      assert_response 200
      response.should render_template("profiles/show")
      response.should include(@user.full_name)
      response.should include(@user.email)
      
      #we restore the visibility to the default value
      @user.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
    end
    
    it "should be able to see a user's public and private profiles with visibility :everybody" do
      login_as(@user)
      #first we fill the user profile
      @user_public_1.profile.update_attributes Factory.attributes_for(:profile)

      #we set the visibility to :everybody and try to see the profile
      @user_public_1.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:everybody))
      get :show , :user_id => @user_public_1.to_param
      pending "Redo after redirect to user show"
      assert_response 200
      response.should render_template("profiles/show")
      response.should include(@user_public_1.full_name)
      response.should include(@user_public_1.email)
      
      #we restore the visibility to the default value
      @user_public_1.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
    end

    it "should be able to see a user's public and private profiles with visibility :members" do
      login_as(@user)
      #first we fill the user profile
      @user_public_1.profile.update_attributes Factory.attributes_for(:profile)

      #we set the visibility to :members and try to see the profile
      @user_public_1.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:members))
      get :show , :user_id => @user_public_1.to_param
      pending "Redo after redirect to user show"
      assert_response 200
      response.should render_template("profiles/show")
      response.should include(@user_public_1.full_name)
      response.should include(@user_public_1.email)
      
      #we restore the visibility to the default value
      @user_public_1.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
    end

    it ("should be able to see a user's public and private profiles with visibility :public_fellows " +
      "if the other user is in the same public or private space") do
      login_as(@user_public_1)
      #first we fill the user profile
      @user_public_2.profile.update_attributes Factory.attributes_for(:profile)

      #we set the visibility to :public_fellows and try to see the profile
      @user_public_2.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
      get :show , :user_id => @user_public_2.to_param
      pending "Redo after redirect to user show"
      assert_response 200
      response.should render_template("profiles/show")
      response.should include(@user_public_2.full_name)
      response.should include(@user_public_2.email)
      
      #we restore the visibility to the default value
      @user_public_2.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
    end
    
    it ("should be able to see ONLY a user's public profile (NOT the private profile) with visibility " +
      ":public_fellows if the other user is NOT in the same public or private space") do
      login_as(@user)
      #first we fill the user profile
      @user_public_1.profile.update_attributes Factory.attributes_for(:profile)

      #we set the visibility to :public_fellows and try to see the profile
      @user_public_1.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
      get :show , :user_id => @user_public_1.to_param
      pending "Redo after redirect to user show"
      assert_response 200
      response.should render_template("profiles/show")
      response.should include(@user_public_1.full_name)
      response.should_not include(@user_public_1.email)
      
      #we restore the visibility to the default value
      @user_public_1.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
    end
    
    it ("should be able to see a user's public and private profiles with visibility :private_fellows " +
      "if the other user is in the same PRIVATE space") do
      login_as(@user)
      #first we fill the user profile
      @admin.profile.update_attributes Factory.attributes_for(:profile)

      #we set the visibility to :private_fellows and try to see the profile
      @admin.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:private_fellows))
      get :show , :user_id => @admin.to_param
      pending "Redo after redirect to user show"
      assert_response 200
      response.should render_template("profiles/show")
      response.should include(@admin.full_name)
      response.should include(@admin.email)
      
      #we restore the visibility to the default value
      @admin.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
    end
    
    it ("should be able to see ONLY a user's public profile (NOT the private profile) with visibility " +
      ":private_fellows if the other user is NOT in the same PRIVATE space") do
      login_as(@user_public_1)

      #first we fill the user profile
      @user_public_2.profile.update_attributes Factory.attributes_for(:profile)

      #we set the visibility to :private_fellows and try to see the profile
      @user_public_2.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:private_fellows))
      get :show , :user_id => @user_public_2.to_param
      pending "Redo after redirect to user show"
      assert_response 200
      response.should render_template("profiles/show")
      response.should include(@user_public_2.full_name)
      response.should_not include(@user_public_2.email)
      
      #we restore the visibility to the default value
      @user_public_2.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
    end

    it "should be able to see ONLY a user's public profile (NOT the private profile) with visibility :nobody" do
      login_as(@user)
      #first we fill the user profile
      @admin.profile.update_attributes Factory.attributes_for(:profile)

      #we set the visibility to :nobody and try to see the profile
      @admin.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:nobody))
      get :show , :user_id => @admin.to_param
      pending "Redo after redirect to user show"
      assert_response 200
      response.should render_template("profiles/show")
      response.should include(@admin.full_name)
      response.should_not include(@admin.email)
      
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
    it "should NOT be able to get the edit view for anyone's profile" do
      get :edit, :user_id => @invited.to_param
      assert_response 403
      get :edit, :user_id => @user.to_param
      assert_response 403
    end
    it "shoud NOT be able to edit anyone's profile" do 
      #first we fill the user profile
      @invited.profile.update_attributes Factory.attributes_for(:profile)
      
      valid_attributes = Factory.attributes_for(:profile)
      valid_attributes["user_attributes"] = {"id"=>@invited.id, "login"=>@invited.login, "email"=>"newemail@gmail.com"}
      put :update, :user_id => @invited.to_param, :profile => valid_attributes              
      assert_response 403
    end
    it "should NOT be able to delete anyone's profile" do
      @invited.profile.update_attributes Factory.attributes_for(:profile)
      expect {
        delete :destroy, :user_id => @invited.to_param
        assert_response 403
      }.not_to change{ Profile.count }
    end
    
    #basic visibility tests because admin status will not affect visibility behaviour,
    #it has already been tested in the previous describe block
    
    it "should be able to see his public and private profiles with visibility :everybody" do
      #first we fill the user profile
      @admin.profile.update_attributes Factory.attributes_for(:profile)

      #we set the visibility to :everybody and try to see the profile
      @admin.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:everybody))
      get :show , :user_id => @admin.to_param
      pending "Redo after redirect to user show"
      assert_response 200
      response.should render_template("profiles/show")
      response.should include(@admin.full_name)
      response.should include(@admin.email)
      
      #we restore the visibility to the default value
      @admin.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
    end
    
    it "should be able to see his public and private profiles with visibility :nobody" do
      #first we fill the user profile
      @admin.profile.update_attributes Factory.attributes_for(:profile)
      
      #we set the visibility to :nobody and try to see the profile
      @admin.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:nobody))
      get :show , :user_id => @admin.to_param
      pending "Redo after redirect to user show"
      assert_response 200
      response.should render_template("profiles/show")
      response.should include(@admin.full_name)
      response.should include(@admin.email)
      
      #we restore the visibility to the default value
      @admin.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
    end
    
    it "should be able to see a user's public and private profiles with visibility :everybody" do
      #first we fill the user profile
      @user.profile.update_attributes Factory.attributes_for(:profile)

      #we set the visibility to :everybody and try to see the profile
      @user.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:everybody))
      get :show , :user_id => @user.to_param
      pending "Redo after redirect to user show"
      assert_response 200
      response.should render_template("profiles/show")
      response.should include(@user.full_name)
      response.should include(@user.email)
      
      #we restore the visibility to the default value
      @user.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
    end
    
    it "should be able to see ONLY a user's public profile (NOT the private profile) with visibility :nobody" do
      #first we fill the user profile
      @user.profile.update_attributes Factory.attributes_for(:profile)

      #we set the visibility to :nobody and try to see the profile
      @user.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:nobody))
      get :show , :user_id => @user.to_param
      pending "Redo after redirect to user show"
      assert_response 200
      response.should render_template("profiles/show")
      response.should include(@user.full_name)
      response.should_not include(@user.email)
      
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
    
    it "should NOT be able to get the edit view for anyone's profile" do
      get :edit, :user_id => @invited.to_param
      assert_response 302
      response.should redirect_to(new_session_path)
      get :edit, :user_id => @user.to_param
      assert_response 302
      response.should redirect_to(new_session_path)
    end
    it "shoud NOT be able to edit anyone's profile" do 
      #first we fill the user profile
      @invited.profile.update_attributes Factory.attributes_for(:profile)
      valid_attributes = Factory.attributes_for(:profile)
      valid_attributes["user_attributes"] = {"id"=>@invited.id, "login"=>@invited.login, "email"=>"newemail@gmail.com"}
      put :update, :user_id => @invited.to_param, :profile => valid_attributes              
      assert_response 302
      response.should redirect_to(new_session_path)
    end
    it "should NOT be able to delete anyone's profile" do
      @invited.profile.update_attributes Factory.attributes_for(:profile)
      expect {
        delete :destroy, :user_id => @invited.to_param
        assert_response 302
        response.should redirect_to(new_session_path)
      }.not_to change{ Profile.count }
    end
  
    it "should be able to see a user's public and private profiles with visibility :everybody" do
      #first we fill the user profile
      @invited.profile.update_attributes Factory.attributes_for(:profile)

      #we set the visibility to :everybody and try to see the profile
      @invited.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:everybody))
      get :show , :user_id => @invited.to_param
      pending "Redo after redirect to user show"
      assert_response 200
      response.should render_template("profiles/show")
      response.should include(@invited.full_name)
      response.should include(@invited.email)
      
      #we restore the visibility to the default value
      @invited.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
    end

    it "should be able to see ONLY a user's public profile (NOT the private profile) with visibility :members" do
      #first we fill the user profile
      @invited.profile.update_attributes Factory.attributes_for(:profile)

      #we set the visibility to :members and try to see the profile
      @invited.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:members))
      get :show , :user_id => @invited.to_param
      pending "Redo after redirect to user show"
      assert_response 200
      response.should render_template("profiles/show")
      response.should include(@invited.full_name)
      response.should_not include(@invited.email)
      
      #we restore the visibility to the default value
      @invited.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
    end

    it "should be able to see ONLY a user's public profile (NOT the private profile) with visibility :public_fellows" do
      #first we fill the user profile
      @invited.profile.update_attributes Factory.attributes_for(:profile)

      #we set the visibility to :public_fellows and try to see the profile
      @invited.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
      get :show , :user_id => @invited.to_param
      pending "Redo after redirect to user show"
      assert_response 200
      response.should render_template("profiles/show")
      response.should include(@invited.full_name)
      response.should_not include(@invited.email)
      
      #we restore the visibility to the default value
      @invited.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
    end
    
    it "should be able to see ONLY a user's public profile (NOT the private profile) with visibility :private_fellows" do
      #first we fill the user profile
      @invited.profile.update_attributes Factory.attributes_for(:profile)

      #we set the visibility to :private_fellows and try to see the profile
      @invited.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:private_fellows))
      get :show , :user_id => @invited.to_param
      pending "Redo after redirect to user show"
      assert_response 200
      response.should render_template("profiles/show")
      response.should include(@invited.full_name)
      response.should_not include(@invited.email)
      
      #we restore the visibility to the default value
      @invited.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:public_fellows))
    end

    it "should be able to see ONLY a user's public profile (NOT the private profile) with visibility :nobody" do
      #first we fill the user profile
      @invited.profile.update_attributes Factory.attributes_for(:profile)

      #we set the visibility to :nobody and try to see the profile
      @invited.profile.update_attribute(:visibility, Profile::VISIBILITY.index(:nobody))
      get :show , :user_id => @invited.to_param
      pending "Redo after redirect to user show"
      assert_response 200
      response.should render_template("profiles/show")
      response.should include(@invited.full_name)
      response.should_not include(@invited.email)
      
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
