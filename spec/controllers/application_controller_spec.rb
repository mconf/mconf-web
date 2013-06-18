require "spec_helper"

describe ApplicationController do

  include ActionController::AuthenticationTestHelper

  render_views

  describe "Rooms with owner type = User" do

    before(:each) do
      @user_owner = Factory(:user)
      @bbb_room_user_private = Factory(:bigbluebutton_room, :owner_id => @user_owner.id, :owner_type => "User" )
    end

    it "should return false because the user can't create the room" do
      @user_guest = Factory(:user)
      login_as @user_guest
      (controller.bigbluebutton_can_create? @bbb_room_user_private, nil).should be_false
    end
    it "should return true because the user is the owner of the room" do
      login_as @user_owner
      (controller.bigbluebutton_can_create? @bbb_room_user_private, nil).should be_true
    end
  end

  describe "Rooms with owner type = Space" do

    before(:each) do
      @private_space = Factory(:private_space)
      @bbb_room_space_private = Factory(:bigbluebutton_room, :owner_id => @private_space.id, :owner_type => "Space" )
    end

    it "should return false because the user can't create the room (doesn't belong to the space)" do
      @user_not_in_space = Factory(:user)
      login_as @user_not_in_space
      (controller.bigbluebutton_can_create? @bbb_room_space_private, nil).should be_false
    end
    it "should return true because the user belongs to the space" do
      @user_in_space = Factory(:admin_performance, :stage => @private_space).agent
      login_as @user_in_space
      (controller.bigbluebutton_can_create? @bbb_room_space_private, nil).should be_true
    end
  end
  
end
