require 'spec_helper'

# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

describe AdminsController do
  render_views

  describe "#new_user" do
    context "logged as a superuser" do
      let(:superuser) { FactoryGirl.create(:superuser) }
      before(:each) { sign_in(superuser) }

      context "template and view" do
        before(:each) { get :new_user }
        it { should render_with_layout("application") }
        it { should render_template("admins/new_user") }
      end

      context "template and view via xhr" do
        before(:each) { xhr :get, :new_user }
        it { should_not render_with_layout() }
        it { should render_template("admins/new_user") }
      end

      it "assigns @user" do
        get :new_user
        should assign_to(:user).with(instance_of(User))
      end
    end

    context "logged as a regular user" do
      let(:user) { FactoryGirl.create(:user) }
      before(:each) { 
        sign_in(user)
        get :new_user
      }

      it "raises AccessDenied" do
        bypass_rescue
        expect { get :new_user }.to raise_error(CanCan::AccessDenied)
      end

      it { should set_the_flash.to(I18n.t('admins.access_forbidden')) }
      it { should redirect_to root_path }
    end

    context "a anonymous user" do
      before(:each) { get :new_user }

      it "raises AccessDenied" do
        bypass_rescue
        expect { get :new_user }.to raise_error(CanCan::AccessDenied)
      end

      it { should redirect_to root_path }
    end
  end

  describe "#create_user"  do
    let(:superuser) { FactoryGirl.create(:superuser) }
    before(:each) { sign_in(superuser) }

    describe "creates a new user with valid attributes" do
      let(:user) { FactoryGirl.build(:user) }
      before(:each) {
        expect {
          post :create_user, user: {
            email: user.email, _full_name: "Maria Test", username: "maria-test", 
            password: "test123", password_confirmation: "test123"
          }
        }.to change(User, :count).by(1)
      }

      it { should set_the_flash.to(I18n.t('admins.user.created')) }
      it { should redirect_to manage_users_path }
      it { User.last.confirmed?.should be true }
      it { User.last.approved?.should be true }
      end

    describe "creates a new user with invalid attributes" do
      before(:each) {
        expect {
          test = post :create_user, user: {
            email: "test@test.com", _full_name: "Maria Test", username: "maria-test", 
            password: "test123", password_confirmation: "test1234"
          }
        }.not_to change(User, :count)
      }

      it { should set_the_flash.to(I18n.t('admins.user.error')) }
      it { should redirect_to manage_users_path }
      end

  end

end
