require "spec_helper"

describe AttachmentsController do

  include ActionController::AuthenticationTestHelper

  render_views

  before(:each) do
    #the superuser
    @superuser = Factory(:superuser)
    #a private space and three users in that space
    @private_space = Factory(:private_space)
    @private_space2 = Factory(:private_space_with_repository)
    @admin = Factory(:admin_performance, :stage => @private_space).agent
    @admin2 = Factory(:admin_performance, :stage => @private_space2).agent
    @user = Factory(:user_performance, :stage => @private_space).agent
    @user_space2 =  Factory(:user_performance, :stage => @private_space2).agent
    @invited = Factory(:invited_performance, :stage => @private_space).agent
    #a public space
    @public_space = Factory(:public_space)
  end

  describe "The admin of a space" do
    it "should be able to delete attachments in his space repository" do
      login_as(@admin2)
      @attachment = Factory.create(:attachment,:space => @private_space2,:author => @user_space2)
      delete :destroy, :id => @attachment.to_param, :space_id => @private_space2.to_param
      assert_nil Attachment.find_by_id(@attachment.id)
    end
    it "should not be able to see space repository if it is not enabled" do
      login_as(@admin)
      get :index, :space_id => @private_space.to_param
      assert_response 403
    end
    it "should be able to see space repository if it is enabled" do
      login_as(@admin2)
      get :index, :space_id => @private_space2.to_param
      assert_response 200
      response.should render_template("attachments/index")
    end
    it"should be able to show attachments in his space repository"do
      login_as(@admin2)
      @attachment = Factory.create(:attachment,:space => @private_space2,:author => @user_space2)
      get :show, :space_id => @private_space2.to_param, :id => @attachment.to_param
      assert_response 200
    end
    it"should be able to create a new version of an attachment"do
      login_as(@admin2)
      @attachment = Factory.create(:attachment,:space => @private_space2,:author => @user_space2)
      put :update, :space_id => @private_space2.to_param, :id => @attachment.to_param ,:attachment => Factory.attributes_for(:attachment)
    end
  end

  describe "A logged user" do
    it "should be able to delete his own attachment" do
      login_as(@user_space2)
      @attachment = Factory(:attachment,:space => @private_space2,:author => @user_space2)
      delete :destroy ,:id => @attachment, :space_id => @private_space2.to_param
      assert_nil Attachment.find_by_id(@attachment.id)
      assert_response 302
    end
    it"should be able to create a new version of an attachment in a public space"do
      login_as(@user)
      @public_space_with_repository=Factory(:public_space_with_repository)
      @attachment = Factory(:attachment,:space => @public_space_with_repository,:author => @user_space2)
      put :update, :space_id => @public_space_with_repository.to_param, :id=>@attachment.id ,:attachment => Factory.attributes_for(:attachment)
    end
    it"should be able to create a new version of an attachment in a private space if he belongs to its"do
      login_as(@user_space2)
      @private_space_with_repository=Factory(:private_space_with_repository)
      @attachment = Factory(:attachment,:space => @private_space_with_repository,:author => @admin2)
      put :update, :space_id => @private_space_with_repository.to_param, :id=>@attachment.id ,:attachment => Factory.attributes_for(:attachment)
    end
  end

  describe "A not logged user" do
    it "should be able to see space repository in a public space if it is enabled"do
      @public_space_with_repository=Factory(:public_space_with_repository)
      get :index, :space_id =>  @public_space_with_repository.to_param
      assert_response 200
      response.should render_template("attachments/index")
    end
    it "should not be able to see space repository in a private space "do
      @private_space_with_repository=Factory(:private_space_with_repository)
      get :index, :space_id =>  @private_space_with_repository.to_param
      assert_response 302
      response.should redirect_to(new_session_path)
    end
  end

  describe "A Superadmin" do
    before(:each) do
      login_as(@superuser)
    end

    it "should be able to see space repository" do
      get :index, :space_id => @private_space.to_param
      assert_response 200
      response.should render_template("attachments/index")
    end
  end

end
