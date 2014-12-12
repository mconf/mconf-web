# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe ConfirmationsController do
  render_views
  before { @request.env["devise.mapping"] = Devise.mappings[:user] }

  describe "#new" do
    describe "if registrations are enabled in the site" do

      context "for an anonymous user" do
        before(:each) { get :new }
        it { should respond_with(:success) }
      end

      context "for a signed in but unconfirmed user" do
        let(:user) { FactoryGirl.create(:unconfirmed_user) }
        before { login_as(user) }
        before(:each) { get :new }
        it { should respond_with(:success) }
      end

      context "for a signed in and already confirmed user" do
        let(:user) { FactoryGirl.create(:user) }
        before { login_as(user) }
        before(:each) { get :new }
        it { should redirect_to(my_home_path) }
        it { should set_the_flash.to I18n.t('confirmations.check_already_confirmed.already_confirmed') }
      end
    end

    describe "if registrations are disabled in the site" do
      before { Site.current.update_attribute(:registration_enabled, false) }
      it { expect { get :new }.to raise_error(ActionController::RoutingError) }
    end
  end

  describe "#after_resending_confirmation_instructions_path_for" do
    subject { controller.send(:after_resending_confirmation_instructions_path_for, "user") }

    context "if it's navigational format" do
      before { controller.stub(:is_navigational_format?).and_return(true) }

      context "if there's a user signed in" do
        let(:user) { FactoryGirl.create(:user) }
        before { login_as(user) }
        it { subject.should eql(my_home_path) }
      end

      context "if there's no user signed in" do
        it { subject.should eql(controller.new_session_path("user")) }
      end
    end

    context "if it's not navigational format" do
      before { controller.stub(:is_navigational_format?).and_return(false) }
      it { subject.should eql("/") }
    end
  end

end
