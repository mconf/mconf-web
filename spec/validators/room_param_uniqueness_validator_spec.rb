# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe RoomParamUniquenessValidator do
  let!(:target) { RoomParamUniquenessValidator.new({ attributes: { any: 1 } }) }
  let(:message) { "has already been taken" }

  context "accepts a custom message in the options" do
    let(:user) { FactoryGirl.create(:user) }
    let(:room) { FactoryGirl.create(:bigbluebutton_room) }
    let(:custom_error) { "my custom error message" }
    let(:target) { RoomParamUniquenessValidator.new({ attributes: { any: 1 }, message: custom_error }) }

    it {
      target.validate_each(user, "my_attribute", room.param)
      user.errors.should have_key(:my_attribute)
      user.errors[:my_attribute].should include(custom_error)
    }
  end

  context "for User" do
    let!(:user_room) { FactoryGirl.create(:bigbluebutton_room) }
    let!(:user) { FactoryGirl.create(:user, bigbluebutton_room: user_room) }

    # to clear the other validations and make sure everything's ok
    before { user.valid? }

    it "when the value is empty" do
      target.validate_each(user, "username", "")
      user.errors.should be_empty
    end

    it "when the value is nil" do
      target.validate_each(user, "username", nil)
      user.errors.should be_empty
    end

    it "when there's no conflict" do
      target.validate_each(user, "username", "new-value")
      user.errors.should be_empty
    end

    context "when there's a conflict" do
      let!(:room) { FactoryGirl.create(:bigbluebutton_room) }
      it {
        target.validate_each(user, "username", room.param)
        user.errors.should have_key(:username)
        user.errors.messages[:username].should include(message)
      }
    end

    it "ignores the user's own room" do
      target.validate_each(user, "username", user.bigbluebutton_room.param)
      user.errors.should be_empty
    end
  end

  context "for Space" do
    let!(:space_room) { FactoryGirl.create(:bigbluebutton_room) }
    let!(:space) { FactoryGirl.create(:space, bigbluebutton_room: space_room) }

    # to clear the other validations and make sure everything's ok
    before { space.valid? }

    it "when the value is empty" do
      target.validate_each(space, "permalink", "")
      space.errors.should be_empty
    end

    it "when the value is nil" do
      target.validate_each(space, "permalink", nil)
      space.errors.should be_empty
    end

    it "when there's no conflict" do
      target.validate_each(space, "permalink", "new-value")
      space.errors.should be_empty
    end

    context "when there's a conflict" do
      let!(:room) { FactoryGirl.create(:bigbluebutton_room) }
      it {
        target.validate_each(space, "permalink", room.param)
        space.errors.should have_key(:permalink)
        space.errors.messages[:permalink].should include(message)
      }
    end

    it "ignores the space's own room" do
      target.validate_each(space, "permalink", space.bigbluebutton_room.param)
      space.errors.should be_empty
    end
  end

end
