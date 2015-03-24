# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe SitesController do
  render_views

  # Test that devise's authenticate_user! is being called
  describe "disallow member-only actions when not logged in" do
    let(:site) { FactoryGirl.create(:site) }
    after { response.should redirect_to new_user_session_path }

    it { get :show, :id => site }
    it { get :edit, :id => site }
    it { put :update, :id => site, :site => {'these' => 'params'} }
  end

  describe "#show" do
    it "uses the layout no_sidebar"
  end

  describe "#edit" do
    it "uses the layout no_sidebar"
  end

  describe "#update" do
    it "removes empty values from the visible_locales"
  end

  describe "abilities", :abilities => true do
    let(:site) { FactoryGirl.create(:site) }

    context "for a normal user:" do
      before(:each) { login_as(FactoryGirl.create(:user)) }

      context "cannot access #show" do
        let(:do_action) { get :show, :id => site }
        it_should_behave_like "it cannot access an action"
      end

      context "cannot access #edit" do
        let(:do_action) { get :edit, :id => site }
        it_should_behave_like "it cannot access an action"
      end

      context "cannot access #update" do
        let(:do_action) { post :update, :id => site, :site => {'these' => 'params'} }
        it_should_behave_like "it cannot access an action"
      end
    end

    context "for a superuser:" do
      before(:each) { login_as(FactoryGirl.create(:superuser)) }

      context "can access #show" do
        let(:do_action) { get :show, :id => site }
        it_should_behave_like "it can access an action"
      end

      context "can access #edit" do
        let(:do_action) { get :edit, :id => site }
        it_should_behave_like "it can access an action"
      end

      context "can access #update" do
        let(:do_action) { post :update, :id => site, :site => {} }
        it_should_behave_like "it can access an action"
      end
    end

  end

end
