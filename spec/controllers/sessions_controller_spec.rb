# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe SessionsController do

  describe "#new" do
    before { @request.env["devise.mapping"] = Devise.mappings[:user] }

    context "if there's already a user signed in" do
      before do
        login_as(FactoryGirl.create(:user))
        get :new
      end
      it { response.should redirect_to my_home_path }
    end
  end

  describe "#create" do
    let(:old_current_local_sign_in_at) { Time.now.utc - 1.day }
    let(:user) { FactoryGirl.create(:user) }
    before(:each) {
      #setting a previous local sign in date
      user.update_attribute(:current_local_sign_in_at, old_current_local_sign_in_at)
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @startedAt = Time.now.utc
      PublicActivity.with_tracking do
        post :create, user: { login: user.email, password: user.password }
      end
    }

    it { response.should redirect_to my_home_path }
    it "updates local sign in date" do
      user.reload.current_local_sign_in_at.to_i.should be >= @startedAt.to_i
    end
    it "sets the local sign in date to the same as current_sign_in_at" do
      user.reload
      user.current_local_sign_in_at.to_i.should eql(user.current_sign_in_at.to_i)
    end
  end

  # The class used to authenticate users via LDAP is a custom strategy for devise, that has its
  # own unit tests. The block here is to test it integrated with devise, calling the action
  # directly on the controller.
  context "authentication via LDAP" do

    # TODO: post user information to /users/login, mock the LDAP connection somehow, and check
    #   the user will actually be authenticated and sign in by devise
    it "authenticates a user via LDAP and logs the user in"
  end

end
