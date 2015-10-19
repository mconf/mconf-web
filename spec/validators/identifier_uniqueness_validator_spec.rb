# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe IdentifierUniquenessValidator do
  let!(:target) { IdentifierUniquenessValidator.new({ attributes: { any: 1 } }) }
  let(:message) { "has already been taken" }

  context "accepts a custom message in the options" do
    let(:user) { FactoryGirl.create(:user) }
    let(:other_user) { FactoryGirl.create(:user) }
    let(:custom_error) { "my custom error message" }
    let(:target) { IdentifierUniquenessValidator.new({ attributes: { any: 1 }, message: custom_error }) }

    it {
      target.validate_each(user, "my_attribute", other_user.username)
      user.errors.should have_key(:my_attribute)
      user.errors[:my_attribute].should include(custom_error)
    }
  end

  context "for User" do
    let!(:user) { FactoryGirl.create(:user) }

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

    context "when there's a conflict with another user" do
      let!(:other_user) { FactoryGirl.create(:user) }
      it {
        target.validate_each(user, "username", other_user.username)
        user.errors.should have_key(:username)
        user.errors.messages[:username].should include(message)
      }
    end

    context "when there's a conflict with a disabled user" do
      let!(:other_user) { FactoryGirl.create(:user, disabled: true) }
      it {
        target.validate_each(user, "username", other_user.username)
        user.errors.should have_key(:username)
        user.errors.messages[:username].should include(message)
      }
    end

    context "when there's a conflict with another user ignoring case" do
      let!(:other_user) { FactoryGirl.create(:user, username: "ANY-username") }
      it {
        target.validate_each(user, "username", "any-USERnaME")
        user.errors.should have_key(:username)
        user.errors.messages[:username].should include(message)
      }
    end

    context "when there's a conflict with a space" do
      let!(:space) { FactoryGirl.create(:space) }
      it {
        target.validate_each(user, "username", space.permalink)
        user.errors.should have_key(:username)
        user.errors.messages[:username].should include(message)
      }
    end

    context "when there's a conflict with a disabled space" do
      let!(:space) { FactoryGirl.create(:space, disabled: true) }
      it {
        target.validate_each(user, "username", space.permalink)
        user.errors.should have_key(:username)
        user.errors.messages[:username].should include(message)
      }
    end

    context "when there's a conflict with a space ignoring case" do
      let!(:space) { FactoryGirl.create(:space, permalink: "ANY-username") }
      it {
        target.validate_each(user, "username", "any-USERnaME")
        user.errors.should have_key(:username)
        user.errors.messages[:username].should include(message)
      }
    end

    it "ignores the user himself" do
      target.validate_each(user, "username", user.username)
      user.errors.should be_empty
    end
  end

  context "for Space" do
    let!(:space) { FactoryGirl.create(:space) }

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

    context "when there's a conflict with another space" do
      let!(:another_space) { FactoryGirl.create(:space) }
      it {
        target.validate_each(space, "permalink", another_space.permalink)
        space.errors.should have_key(:permalink)
        space.errors.messages[:permalink].should include(message)
      }
    end

    context "when there's a conflict with a disabled space" do
      let!(:another_space) { FactoryGirl.create(:space, disabled: true) }
      it {
        target.validate_each(space, "permalink", another_space.permalink)
        space.errors.should have_key(:permalink)
        space.errors.messages[:permalink].should include(message)
      }
    end

    context "when there's a conflict with another space ignoring case" do
      let!(:another_space) { FactoryGirl.create(:space, permalink: "ANY-username") }
      it {
        target.validate_each(space, "permalink", "any-USERnaME")
        space.errors.should have_key(:permalink)
        space.errors.messages[:permalink].should include(message)
      }
    end

    context "when there's a conflict with a user" do
      let!(:user) { FactoryGirl.create(:user) }
      it {
        target.validate_each(space, "permalink", user.username)
        space.errors.should have_key(:permalink)
        space.errors.messages[:permalink].should include(message)
      }
    end

    context "when there's a conflict with a disabled user" do
      let!(:user) { FactoryGirl.create(:user, disabled: true) }
      it {
        target.validate_each(space, "permalink", user.username)
        space.errors.should have_key(:permalink)
        space.errors.messages[:permalink].should include(message)
      }
    end

    context "when there's a conflict with a user ignoring case" do
      let!(:user) { FactoryGirl.create(:user, username: "ANY-username") }
      it {
        target.validate_each(space, "permalink", "any-USERnaME")
        space.errors.should have_key(:permalink)
        space.errors.messages[:permalink].should include(message)
      }
    end

    it "ignores the space itself" do
      target.validate_each(space, "permalink", space.permalink)
      space.errors.should be_empty
    end
  end

end
