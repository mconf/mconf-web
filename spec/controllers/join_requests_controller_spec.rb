# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe JoinRequestsController do
  render_views

  describe "#index" do
    let(:space) { FactoryGirl.create(:space) }
    let(:user) { FactoryGirl.create(:superuser) }
    before(:each) { sign_in(user) }

    context "template and layout" do
      before(:each) { get :index, :space_id => space.to_param }
      it { should render_template('index') }
      it { should render_with_layout('spaces_show') }
    end

    it "assigns @space"
    it "assigns @join_requests"
    it "assigns @webconf_room"
  end

  describe "#new" do
    it "if the user is already a member of the space redirects to the space's home"
    it "assigns @user_is_admin"
    it "template and layout"

    context "if the user is an admin of the target space" do
      it "assigns @users"
      it "assigns @checked_users"
      it "template and layout"
    end
  end

  it "#create"
  it "#update"
  it "#destroy"

  describe "abilities", :abilities => true do
    render_views(false)
    it "abilities for join requests"
  end
end
