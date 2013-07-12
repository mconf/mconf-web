require "spec_helper"

describe ApplicationController do

  include ActionController::AuthenticationTestHelper

  render_views

  describe "#bigbluebutton_can_create?" do

    context "for user rooms" do
      let(:user) { Factory(:user) }

      it "returns false if user is not the owner of the room" do
        another_user = Factory(:user)
        login_as(another_user)
        controller.bigbluebutton_can_create?(user.bigbluebutton_room, nil).should be_false
      end

      it "returns true if user is the owner of the room" do
        login_as(user)
        controller.bigbluebutton_can_create?(user.bigbluebutton_room, nil).should be_true
      end
    end

    context "for space rooms" do
      let(:private_space) { Factory(:private_space) }
      let(:public_space) { Factory(:public_space) }

      context "when the space is private" do
        it "returns false if the user doesn't belong to the space" do
          user = Factory(:user)
          login_as(user)
          controller.bigbluebutton_can_create?(private_space.bigbluebutton_room, nil).should be_false
        end

        it "returns true if the user belongs to the space" do
          user = Factory(:admin_performance, :stage => private_space).agent
          login_as(user)
          controller.bigbluebutton_can_create?(private_space.bigbluebutton_room, nil).should be_true
        end
      end

      context "when the space is public" do
        it "returns false if the user doesn't belong to the space" do
          user = Factory(:user)
          login_as(user)
          controller.bigbluebutton_can_create?(public_space.bigbluebutton_room, nil).should be_false
        end

        it "returns true if the user belongs to the space" do
          user = Factory(:admin_performance, :stage => public_space).agent
          login_as(user)
          controller.bigbluebutton_can_create?(public_space.bigbluebutton_room, nil).should be_true
        end
      end
    end

  end
end
