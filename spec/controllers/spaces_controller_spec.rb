# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe SpacesController do

  render_views

  before(:each) do
    # the superuser
    @superuser = FactoryGirl.create(:superuser)

    # # private spaces
    @private_space = FactoryGirl.create(:private_space)
    @user = FactoryGirl.create(:user)
    # @invited = FactoryGirl.create(:invited_performance, :stage => @private_space).agent

    @private_space2 = FactoryGirl.create(:private_space)

    # a public space
    @public_space = FactoryGirl.create(:public_space)
  end

  describe "A Superadmin", :super_admin => true do
    before(:each) do
      sign_in @superuser
    end

    it "should be able to create a new space" do
      valid_attributes = FactoryGirl.attributes_for(:public_space)
      post :create, :space => valid_attributes
      assert_response 302
      space = Space.find_by_name(valid_attributes[:name])
      response.should redirect_to(space_path(space))
    end
    it "should be able to see public spaces " do
      get :show, :id => @public_space.to_param
      assert_response 200
      response.should render_template("spaces/show")
    end
    it "should be able to delete a public space" do
      delete :destroy , :id => @public_space.to_param
      assert_response 302
      response.should redirect_to(spaces_url)
    end
    it "should be able to see  private spaces" do
      get :show, :id => @private_space.to_param
      assert_response 200
      response.should render_template("spaces/show")
    end
    it "should be able to delete a private  space" do
      delete :destroy , :id => @private_space.to_param
      assert_response 302
      response.should redirect_to(spaces_url)
    end
  end

  describe "The admin of a space", :space_admin => true do
    before(:each) do
      sign_in @user
      @private_space2.add_member!(@user, 'Admin')
    end

    it "should be authorized to access his own space" do
      get :show, :id => @private_space2.to_param
      assert_response 200
    end

    it "should be able to delete his own space" do
      expect {
      delete :destroy , :id => @private_space2
      }.to change { Space.count }.by(-1)
      assert_response 302
      response.should redirect_to(spaces_url)

    end

    it "should NOT be able to delete other spaces if he isn't the admin" do
      delete :destroy, :id => @private_space.to_param
      assert_response 403
    end
  end

  describe "A logged user", :logged_user => true do
    before(:each) do
      sign_in @user
      @private_space.add_member!(@user)
    end

    it "should be able to create a new space" do
      valid_attributes = FactoryGirl.attributes_for(:public_space)
      post :create, :space=> valid_attributes
      assert_response 302
      space = Space.find_by_name(valid_attributes[:name])
      response.should redirect_to(space_path(space))
    end

    it "should be able to see public spaces" do
      get :show, :id => @public_space.to_param
      assert_response 200
      response.should render_template("spaces/show")
    end
    it "should be able to see private spaces if he is joined to them" do
      get :show, :id => @private_space.to_param
      assert_response 200
      response.should render_template("spaces/show")
    end

    it "should NOT be able to see private spaces if he isn't joined to them" do
      get :show, :id => @private_space2.to_param
      assert_response 403

    end
    it "should NOT be able to delete anyone's space " do
      delete :destroy, :id => @private_space2.to_param
      assert_response 403
    end
  end

  # TODO
  # Redo these tests
  # describe "A invited user" do
  #   login_user

  #   it "should be able to see public spaces" do
  #     get :show, :id => @public_space.to_param
  #     assert_response 200
  #     response.should render_template("spaces/show")
  #   end

  #   it "should NOT be able to delete anyone's space " do
  #     delete :destroy, :id => @private_space.to_param
  #     assert_response 403
  #   end

  #   it "should  NOT be able to create a new space" do
  #     valid_attributes = FactoryGirl.attributes_for(:public_space)
  #     post :create, :space=> valid_attributes
  #     assert_response 302
  #   end

  # end

  describe "A NOT logged user", :not_logged_user => true do
    it "should be able to see public spaces" do
      get :show, :id => @public_space.to_param
      assert_response 200
      response.should render_template("spaces/show")
    end

    it "should NOT be able to see private spaces" do
      private_space3 = FactoryGirl.create(:private_space)
      get :show, :id => private_space3.to_param
      assert_response 302
      response.should redirect_to new_space_join_request_path(:space_id => private_space3)
    end

    it "should NOT be able to delete a space" do
      delete :destroy, :id => @public_space.to_param
      assert_response 302
      response.should redirect_to new_space_join_request_path(:space_id => @public_space)
    end
  end

  describe "a space#bigbluebutton_room is", :bbb_room => true do
    login_admin

    it "created when the space is created" do
      expect {
        post :create, :space => FactoryGirl.attributes_for(:public_space)
      }.to change{ BigbluebuttonRoom.count }.by(1)
      space = Space.last
      room = space.bigbluebutton_room

      room.should_not be_nil
      room.name.should == space.name
      room.owner_id.should == space.id
      room.owner_type.should == space.class.name
    end

    # ps: the room is destroyed when the space (the model) is destroyed
  end

end
