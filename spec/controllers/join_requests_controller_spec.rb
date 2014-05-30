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
    let(:space) { FactoryGirl.create(:space) }
    let(:user) { FactoryGirl.create(:user) }
    let(:jr) { FactoryGirl.create(:join_request, :group => space, :introducer => nil) }

    context "a space admin" do
      before(:each) {
        request.env['HTTP_REFERER'] = space_join_requests_path(space)
        space.add_member!(user, 'Admin')
        jr # create join request now and not on request block
        sign_in(user)
      }

      context "accepts a user request" do
        before(:each) {
          expect {
            put :update, :space_id => space.to_param, :id => jr.id, :join_request => {:processed => true, :accepted => true}
          }.to change{space.pending_join_requests.count}.by(-1)
          jr.reload
        }

        it { should redirect_to(space_join_requests_path(space)) }
        it { space.users.should include(jr.candidate) }
        it { jr.should be_accepted }
        it { jr.introducer.should eq(user) }
      end

      context "accepts a user request and specifies a role" do
        let(:role) { Role.find_by_name_and_stage_type('Admin', 'Space') }
        let(:jr) { FactoryGirl.create(:join_request, :group => space, :role => nil) }
        before(:each) {
          expect {
            put :update, :space_id => space.to_param, :id => jr.id, :join_request => {:role_id => role.id, :processed => true, :accepted => true}
          }.to change{space.pending_join_requests.count}.by(-1)
          jr.reload
        }

        it { should redirect_to(space_join_requests_path(space)) }
        it { space.users.should include(jr.candidate) }
        it { jr.should be_accepted }
        it { jr.introducer.should eq(user) }
        it { jr.role.should eq(role.name) }
        it { jr.candidate.permissions.last.role.should eq(role) }
      end

      context "denies a user request" do
        before(:each) {
          expect {
            put :update, :space_id => space.to_param, :id => jr.id, :join_request => {:processed => true, :accepted => nil}
          }.to change{space.pending_join_requests.count}.by(-1)
          jr.reload
        }

        it { should redirect_to(space_join_requests_path(space)) }
        it { space.users.should_not include(jr.candidate) }
        it { jr.should_not be_accepted }
        it { jr.introducer.should eq(user) }
      end
    end

    context "an invited user" do
      let(:jr) { FactoryGirl.create(:join_request, :group => space, :introducer => nil, :request_type => 'invite') }
      before(:each) {
        request.env['HTTP_REFERER'] = space_path(space)
        jr # create join request now and not on request block
        sign_in(jr.candidate)
      }

      context "accepts request" do
        before(:each) {
          expect {
            put :update, :space_id => space.to_param, :id => jr.id, :join_request => {:processed => true, :accepted => true}
          }.to change{space.pending_invitations.count}.by(-1)
          jr.reload
        }

        it { should redirect_to(space_path(space)) }
        it { jr.should be_accepted }
      end

      context "denies a request" do
        before(:each) {
          expect {
            put :update, :space_id => space.to_param, :id => jr.id, :join_request => {:processed => true, :accepted => nil}
          }.to change{space.pending_invitations.count}.by(-1)
          jr.reload
        }

        it { should redirect_to(space_path(space)) }
        it { jr.should_not be_accepted }
      end
    end

  end

  it "#destroy"

  describe "abilities", :abilities => true do
    render_views(false)
    it "abilities for join requests"
  end
end
