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

    it { should_authorize space, :index, :space_id => space.to_param, :ability_name => :index_join_requests }

    context "template and layout" do
      it { should render_template('index') }
      it { should render_with_layout('spaces_show') }
    end

    context "space admin indexing join requests" do
      it { should assign_to(:space).with(space) }
      it { should assign_to(:join_requests).with([]) }
      skip "should assing_to @webconf" #it { should assign_to(:webconf).with(space.bigbluebutton_room) }
    end

  end

  describe "#new" do
    let(:space) { FactoryGirl.create(:space) }
    let(:user) { FactoryGirl.create(:user) }

    it { should_authorize an_instance_of(JoinRequest), :new, :space_id => space.to_param}

    context "a user that is not a member of the target space" do
      before(:each) { sign_in(user) }

      context "and has no pending join request" do
        context "template and layout" do
          before(:each) { get :new, :space_id => space.to_param }
          it { should render_template('new') }
          it { should render_with_layout('no_sidebar') }
        end
      end

      context "and has already requested membership" do
        before {
          @join_request =
            FactoryGirl.create(:join_request, :group => space, :candidate => user, :request_type => "request")
        }
        before(:each) { get :new, :space_id => space.to_param }
        it { should render_template("new") }
        it { should render_with_layout('no_sidebar') }
        it { should assign_to(:pending_request).with(@join_request) }
      end

      context "and has already been invited" do
        before {
          @join_request =
            FactoryGirl.create(:join_request, :group => space, :candidate => user, :request_type => "invite")
        }
        before(:each) { get :new, :space_id => space.to_param }
        it { should render_template("new") }
        it { should render_with_layout('no_sidebar') }
        it { should assign_to(:pending_request).with(@join_request) }
      end
    end

    context "a user that is a member of the target space" do
      before(:each) {
        space.add_member!(user)
        sign_in(user)
        get :new, :space_id => space.to_param
      }
      it { should redirect_to(space_path(space)) }
      it { should assign_to(:pending_request).with(nil) }
    end

  end

  describe "#show" do
    let(:jr) { FactoryGirl.create(:space_join_request) }
    let(:space) { jr.group }
    let(:user) { FactoryGirl.create(:user) }

    it { should_authorize an_instance_of(JoinRequest), :show, :space_id => space.to_param, :id => jr.id }

    context "a normal user" do
      context "is not the subject of the join request" do
        before(:each) {
          sign_in(user)
          expect {
            get :show, :space_id => space.to_param, :id => jr.id
          }.to raise_error(CanCan::AccessDenied)
        }
      end

      context "is the subject of the join_request" do
        before(:each) {
          sign_in(jr.candidate)
          get :show, :space_id => space.to_param, :id => jr.id
        }

        it { should render_template('show') }
        it { should render_with_layout('no_sidebar') }
      end

      context "is the admin of the space of the join_request" do
        before(:each) {
          space.add_member!(user, 'Admin')
          sign_in(user)
          get :show, :space_id => space.to_param, :id => jr.id
        }

        it { should redirect_to space_join_requests_path(space) }
      end

    end

  end

  describe "#create" do
    let(:user) { FactoryGirl.create(:user) }
    let(:space) { FactoryGirl.create(:space) }
    let(:jr) { FactoryGirl.build(:join_request, :candidate => user, :introducer => nil) }

    it { should_authorize an_instance_of(JoinRequest), :create, :via => :post, :space_id => space.to_param }

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
      it { JoinRequest.last.comment.should eql(jr.comment) }
      it { JoinRequest.last.introducer.should be_nil }
      it { JoinRequest.last.candidate.should eql(user) }
      it { JoinRequest.last.group.should eql(space) }
      it { JoinRequest.last.role.should eql("User") }
      it { JoinRequest.last.request_type.should eql("request") }
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
      it { JoinRequest.last.comment.should eql(jr.comment) }
      it { JoinRequest.last.introducer.should be_nil }
      it { JoinRequest.last.candidate.should eql(user) }
      it { JoinRequest.last.group.should eql(space) }
      it { JoinRequest.last.role.should eql("User") }
      it { JoinRequest.last.request_type.should eql("request") }
    end

    context "params handling" do
      let(:user) { FactoryGirl.create(:user) }
      let(:jr_attributes) { FactoryGirl.attributes_for(:join_request) }
      let(:params) {
        {
          :space_id => space.to_param,
          :controller => "join_requests",
          :action => "create",
          :join_request => jr_attributes
        }
      }

      let(:jr_allowed_params) {
        [ :introducer_id, :role_id, :processed, :accepted, :comment ]
      }
      before {
        jr_attributes.stub(:permit).and_return(jr_attributes)
        controller.stub(:params).and_return(params)
        sign_in(user)
      }
      before(:each) {
        post :create, space_id: space.to_param, join_request: jr_attributes
      }
      it { jr_attributes.should have_received(:permit).at_least(:once).with(*jr_allowed_params) }
    end
  end

  describe "#create?invite=true" do
    let(:space) { FactoryGirl.create(:space) }
    let(:user) { FactoryGirl.create(:user) }
    let(:candidate) { FactoryGirl.create(:user) }
    let!(:role) { Role.find_by(name: 'User', stage_type: 'Space') }
    before(:each) {
      space.add_member!(user, 'Admin')
      sign_in(user)
    }

    it { should_authorize an_instance_of(JoinRequest), :create, :space_id => space.to_param, :via => :post }

    context "admin succesfully invites one user" do
      let(:attributes) {
        {:join_request => FactoryGirl.attributes_for(:join_request, :email => nil, :role_id => role.id) , :candidates => "#{candidate.id}"}
      }

      before(:each) {
        expect {
          post :create, {:invite => true, :space_id => space.to_param}.merge(attributes)
        }.to change{space.pending_invitations.count}.by(1)
      }

      it { should redirect_to(invite_space_join_requests_path(space)) }
      it { should set_the_flash.to(I18n.t('join_requests.create.sent', :users => candidate.username)) }
      it { JoinRequest.last.comment.should eql(attributes[:join_request][:comment]) }
      it { JoinRequest.last.introducer.should eql(user) }
      it { JoinRequest.last.candidate.should eql(candidate) }
      it { JoinRequest.last.group.should eql(space) }
      it { JoinRequest.last.role.should eql(role.name) }
      it { JoinRequest.last.request_type.should eql("invite") }
    end

    context "admin successfully invites more than one user" do
      let(:candidate2) { FactoryGirl.create(:user) }
      let(:attributes) {
        { :join_request => FactoryGirl.attributes_for(:join_request, :email => nil,
          :role_id => role.id), :candidates => "#{candidate.id},#{candidate2.id}" }
      }

      before(:each) {
        expect {
          post :create, {:invite => true, :space_id => space.to_param}.merge(attributes)
        }.to change{space.pending_invitations.count}.by(2)
      }

      it { should redirect_to(invite_space_join_requests_path(space)) }
      it { should set_the_flash.to(I18n.t('join_requests.create.sent', :users => "#{candidate.username}, #{candidate2.username}")) }
    end

    context "admin successfully invites a user and fails to invite another" do
      let(:candidate2) { user } #is invalid because he's already a member
      let!(:errors) { I18n.t('join_requests.create.already_a_member', :name => candidate2.username) }
      let(:attributes) {
        { :join_request => FactoryGirl.attributes_for(:join_request, :email => nil,
          :role_id => role.id), :candidates => "#{candidate.id},#{candidate2.id}" }
      }

      before(:each) {
        expect {
          post :create, {:invite => true, :space_id => space.to_param}.merge(attributes)
        }.to change{space.pending_invitations.count}.by(1)
      }

      it { should redirect_to(invite_space_join_requests_path(space)) }
      it { should set_the_flash.to(I18n.t('join_requests.create.sent', :users => "#{candidate.username}")) }
      it { should set_the_flash.to(I18n.t('join_requests.create.error',
          :errors => errors)) }
    end

    context "admin fails to invite a user" do
      let(:candidate) { user } #is invalid because he's already a member
      let!(:errors) { I18n.t('join_requests.create.already_a_member', :name => candidate.username) }
      let(:attributes) {
        { :join_request => FactoryGirl.attributes_for(:join_request, :email => nil,
          :role_id => role.id), :candidates => "#{candidate.id}" }
      }

      before(:each) {
        expect {
          post :create, {:invite => true, :space_id => space.to_param}.merge(attributes)
        }.to change{space.pending_invitations.count}.by(0)
      }

      it { should redirect_to(invite_space_join_requests_path(space)) }
      it { should set_the_flash.to(I18n.t('join_requests.create.error', :errors => errors)) }
    end
  end

  describe "#invite" do
    let(:space) { FactoryGirl.create(:space) }
    let(:user) { FactoryGirl.create(:user) }

    it { should_authorize space, :invite, :space_id => space.to_param }

    context "if the user is not a member of the space" do
      before(:each) {
        sign_in(user)
        expect { get :invite, :space_id => space.to_param }.to raise_error(CanCan::AccessDenied)
      }

      it { redirect_to(spaces_path(space)) }
    end

    context "if the user is a member of the space, but not an admin" do
      before(:each) {
        space.add_member!(user)
        sign_in(user)
        expect { get :invite, :space_id => space.to_param }.to raise_error(CanCan::AccessDenied)
      }

      it { redirect_to(space_path(space)) }
    end

    context "if the user is an admin of the target space" do
      before(:each) {
        space.add_member!(user, 'Admin')
        sign_in(user)
        get :invite, :space_id => space.to_param
      }

      context "template and layout" do
        it { should render_template('invite') }
        it { should render_with_layout('spaces_show') }
      end

    end
  end

  describe "#update" do
    let(:space) { FactoryGirl.create(:space) }
    let(:user) { FactoryGirl.create(:user) }
    let(:jr) { FactoryGirl.create(:join_request, :group => space, :introducer => nil) }

    it { should_authorize an_instance_of(JoinRequest), :update, :via => :put, :space_id => space.to_param, :id => jr.id }

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
        let(:role) { Role.find_by(name: 'Admin', stage_type: 'Space') }
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

        it { should redirect_to my_home_path }
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
