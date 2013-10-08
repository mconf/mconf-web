# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe ShibbolethController do

  describe "#login" do

    context "redirects to /login if shibboleth is disabled" do
      before { Site.current.update_attributes(:shib_enabled => false) }
      before(:each) { get :login }
      it { should redirect_to(login_path) }
    end

    context "redirects to the user's home if there's already a user logged" do
      let(:user) { FactoryGirl.create(:superuser) }
      before { Site.current.update_attributes(:shib_enabled => true) }
      before(:each) {
        login_as(user)
        get :login
      }
      it { should redirect_to(my_home_path) }
    end

    context "renders an error page if there's not enough information on the session" do
      before { Site.current.update_attributes(:shib_enabled => true) }
      before(:each) { get :login }
      it { should render_template('error') }
      it { should render_with_layout('no_sidebar') }
      it { should set_the_flash.to(I18n.t('shibboleth.login.not_enough_data')) }
    end

  end

  describe "#info" do
    before { Site.current.update_attributes(:shib_enabled => true) }

    context "assigns @data with the data in the session" do
      let(:expected) { { :one => "anything" } }
      before { controller.session[:shib_data] = expected }
      before(:each) { get :info }
      it { should assign_to(:data).with(expected) }
    end

    context "renders with no layout" do
      before(:each) { get :info }
      it { should_not render_with_layout() }
    end
  end

end
