# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe SpacesController do

  render_views

  describe "a superadmin", :super_admin => true do
    before(:each) do
      @superuser = FactoryGirl.create(:superuser)
      @private_space = FactoryGirl.create(:private_space)
      @public_space = FactoryGirl.create(:public_space)
      sign_in @superuser
    end

    it "should be able to create a new space" do
      valid_attributes = FactoryGirl.attributes_for(:public_space)
      post :create, :space => valid_attributes
      assert_response 302
      space = Space.find_by_name(valid_attributes[:name])
      response.should redirect_to(space_path(space))
    end

    it "should be able to see public spaces" do
      get :show, :id => @public_space.to_param
      assert_response 200
      response.should render_template("spaces/show")
    end

    it "should be able to delete a public space" do
      delete :destroy , :id => @public_space.to_param
      assert_response 302
      response.should redirect_to(spaces_url)
    end

    pending "should be able to update a public space"

    it "should be able to see private spaces" do
      get :show, :id => @private_space.to_param
      assert_response 200
      response.should render_template("spaces/show")
    end

    it "should be able to delete a private space" do
      delete :destroy , :id => @private_space.to_param
      assert_response 302
      response.should redirect_to(spaces_url)
    end

    pending "should be able to update a private space"
  end

  describe "the admin of a space", :space_admin => true do
    before(:each) do
      @user = FactoryGirl.create(:user)
      @private_space = FactoryGirl.create(:private_space)
      @private_space.add_member!(@user, 'Admin')
      @private_space2 = FactoryGirl.create(:private_space)
      sign_in @user
    end

    it "should be authorized to access the space" do
      get :show, :id => @private_space.to_param
      assert_response 200
    end

    it "should be able to delete the space" do
      expect {
        delete :destroy, :id => @private_space
      }.to change { Space.count }.by(-1)
      assert_response 302
      response.should redirect_to(spaces_url)
    end

    pending "should be able to update the space"

    it "should not be able to delete spaces he's not a member of" do
      delete :destroy, :id => @private_space2.to_param
      assert_response 403
    end
  end

  describe "a logged user", :logged_user => true do
    before(:each) do
      @user = FactoryGirl.create(:user)
      @private_space = FactoryGirl.create(:private_space)
      @private_space.add_member!(@user)
      @private_space2 = FactoryGirl.create(:private_space)
      @public_space = FactoryGirl.create(:public_space)
      sign_in @user
    end

    it "should be able to create a new space" do
      valid_attributes = FactoryGirl.attributes_for(:public_space)
      post :create, :space => valid_attributes
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

    it "should NOT be able to see private spaces if he is not a member" do
      get :show, :id => @private_space2.to_param
      assert_response 302
      response.should redirect_to new_space_join_request_path(:space_id => @private_space2)
    end

    it "should NOT be able to delete anyone's space" do
      delete :destroy, :id => @private_space2.to_param
      assert_response 403
    end

    pending "should not be able to update a space he's not a member of"
    pending "should not be able to destroy a space he's not a member of"
    pending "should not be able to update a space he's a member of but not admin"
    pending "should not be able to destroy a space he's a member of but not admin"
  end

  # TODO: Redo these tests
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

  describe "an anonymous user", :anonymous_user => true do
    before(:each) do
      @public_space = FactoryGirl.create(:public_space)
    end

    it "should be able to see public spaces" do
      get :show, :id => @public_space.to_param
      assert_response 200
      response.should render_template("spaces/show")
    end

    it "should not be able to see private spaces" do
      private_space3 = FactoryGirl.create(:private_space)
      get :show, :id => private_space3.to_param
      assert_response 403
    end

    it "should not be able to delete a space" do
      delete :destroy, :id => @public_space.to_param
      assert_response 403
    end

    pending "should not be able to update a space"
  end

  describe :bbb_room => true do
    login_admin

    it "creates #bigbluebutton_room when the space is created" do
      expect {
        post :create, :space => FactoryGirl.attributes_for(:public_space)
      }.to change{ BigbluebuttonRoom.count }.by(1)
      space = Space.last
      room = space.bigbluebutton_room

      room.should_not be_nil
      room.name.should eql(space.name)
      room.owner_id.should eql(space.id)
      room.owner_type.should eql(space.class.name)
    end

    # ps: the room is destroyed when the space (the model) is destroyed
  end

end
