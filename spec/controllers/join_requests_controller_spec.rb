# This file is part of  Mconf-Web, a web application that provides access
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
    before(:each) { get :index, :space_id => space.to_param }


    context "template and layout" do
      it { should render_template('index') }
      it { should render_with_layout('spaces_show') }
    end

    context "space admin indexing join requests" do
      it { should assign_to(:space).with(space) }
      it { should assign_to(:join_requests).with([]) }
      pending "should assing_to @webconf" #it { should assign_to(:webconf).with(space.bigbluebutton_room) }
    end

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

  describe "#create" do
    let(:user) { FactoryGirl.create(:user) }
    let(:jr) { FactoryGirl.build(:join_request, :candidate => user, :introducer => nil) }

    context "user requests membership on a public space" do
      let(:space) { FactoryGirl.create(:space, :public => true) }

      before(:each) {
        sign_in(user)
        expect {
          post :create, :space_id => space.to_param, :join_request => jr.attributes
        }.to change{space.join_requests.count}.by(1)
      }

      it { should redirect_to(space_path(space)) }
      it { should assign_to(:space).with(space) }
      it { should set_the_flash.to(I18n.t('join_requests.create.created')) }
    end

    context "user requests membership on a private space" do
      let(:space) { FactoryGirl.create(:space, :public => false) }

      before(:each) {
        sign_in(user)
        expect {
          post :create, :space_id => space.to_param, :join_request => jr.attributes
        }.to change{space.join_requests.count}.by(1)
      }

      it { should redirect_to(spaces_path) }
      it { should assign_to(:space).with(space) }
      it { should set_the_flash.to(I18n.t('join_requests.create.created')) }
    end

  end

  describe "#invite" do
    it "admin succesfully invites one user"
    it "admin successfully invites more than one user"
    it "admin successfully invites a user and fails to invite another"
    it "admin fails to invite user"
  end

  describe "#update" do
    it "space admin accepts requesting user"
    it "space admin denies requesting user"
    it "invited user accepts request"
    it "invited user accepts request"
  end

  it "#destroy"

  describe "abilities", :abilities => true do
    render_views(false)
    it "abilities for join requests"
  end
end
