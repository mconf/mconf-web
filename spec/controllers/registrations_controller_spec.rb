# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe RegistrationsController do
  render_views

  describe "#new" do
    before { @request.env["devise.mapping"] = Devise.mappings[:user] }

    describe "if registrations are enabled in the site" do
      before(:each) { get :new }
      it { should render_template(:new) }
      it { should render_with_layout("no_sidebar") }
    end

    describe "if registrations are disabled in the site" do
      before { Site.current.update_attribute(:registration_enabled, false) }
      before(:each) { get :new }
      it { should redirect_to(root_path) }
      it { should set_the_flash.to(I18n.t("devise.registrations.not_enabled")) }
    end
  end

  describe "#edit" do
    before { @request.env["devise.mapping"] = Devise.mappings[:user] }
    let(:user) { FactoryGirl.create(:superuser) }
    before(:each) { login_as(user) }

    describe "if registrations are enabled in the site" do
      before(:each) { get :edit }
      it { should redirect_to(edit_user_path(user)) }
    end

    describe "if registrations are disabled in the site" do
      # the same as when registrations are enabled
      before { Site.current.update_attributes(:registration_enabled => false) }
      before(:each) { get :edit }
      it { should redirect_to(edit_user_path(user)) }
    end
  end

  describe "#create" do
    before { @request.env["devise.mapping"] = Devise.mappings[:user] }
    let(:attributes) {
      FactoryGirl.attributes_for(:user).slice(:username, :_full_name, :email, :password)
    }

    describe "if registrations are enabled in the site" do
      before(:each) {
        expect {
          post :create, :user => attributes
        }.to change{ User.count }.by(1)
      }
      it { should redirect_to(my_home_path) }
    end

    context "if registrations are disabled in the site" do
      before {
        Site.current.update_attributes(registration_enabled: false)
      }
      before(:each) {
        expect {
          post :create, :user => attributes
        }.not_to change{ User.count }
      }
      it { should redirect_to(root_path) }
      it { should set_the_flash.to(I18n.t("devise.registrations.not_enabled")) }
    end
  end

end
