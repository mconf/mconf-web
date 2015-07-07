# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe JoinRequestsController do
  render_views

  describe "#index" do
    let(:space) { FactoryGirl.create(:space_with_associations) }
    let(:user) { FactoryGirl.create(:superuser) }

    context "with a logged user" do
      before(:each) {
        sign_in(user)
      }

      it { should_authorize space, :index, :space_id => space.to_param, :ability_name => :index_join_requests }

      context "template and layout" do
        before(:each) { get :index, :space_id => space.to_param }
        it { should render_template('index') }
        it { should render_with_layout('spaces_show') }
      end

      context "space admin indexing join requests" do
        before(:each) { get :index, :space_id => space.to_param }
        it { should assign_to(:space).with(space) }
        it { should assign_to(:join_requests).with([]) }
        skip "should assing_to @webconf" #it { should assign_to(:webconf).with(space.bigbluebutton_room) }
      end

      context "when logged in but not authorized" do
        let(:user) { FactoryGirl.create(:user) }
        before(:each) {
          expect {
            get :index, :space_id => space.to_param
          }.to raise_error(CanCan::AccessDenied)
        }
        it { should_not render_template(:index) }
      end
    end

    context "when not logged in" do
      before(:each) { get :index, :space_id => space.to_param }

      it { should redirect_to login_path }
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
          FactoryGirl.create(:join_request, :group => space, :candidate => user, :request_type => JoinRequest::TYPES[:invite])
        }
        before(:each) { get :new, :space_id => space.to_param }
        it { should render_template("new") }
        it { should render_with_layout('no_sidebar') }
        it { should assign_to(:pending_request).with(@join_request) }
      end

      context "and has already been invited" do
        before {
          @join_request =
            FactoryGirl.create(:join_request, :group => space, :candidate => user, :request_type => JoinRequest::TYPES[:invite])
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

    context "an anonymous user with no permission to create a new join request" do
      before(:each) {
        get :new, space_id: space.to_param
      }
      it { should redirect_to(login_path) }
    end
  end

  describe "#show" do
    let(:jr) { FactoryGirl.create(:space_join_request) }
    let(:space) { jr.group }
    let(:user) { FactoryGirl.create(:user) }

    it { should_authorize an_instance_of(JoinRequest), :show, :space_id => space.to_param, :id => jr }

    context "a normal user" do
      context "is not the subject of the join request" do
        before(:each) {
          sign_in(user)
          expect {
            get :show, :space_id => space.to_param, :id => jr
          }.to raise_error(CanCan::AccessDenied)
        }
      end

      context "is the subject of the join request" do
        before(:each) {
          sign_in(jr.candidate)
          get :show, :space_id => space.to_param, :id => jr
        }

        it { should render_template('show') }
        it { should render_with_layout('no_sidebar') }
      end

      context "is the admin of the space of the join request" do
        before(:each) {
          space.add_member!(user, 'Admin')
          sign_in(user)
          get :show, :space_id => space.to_param, :id => jr
        }

        it { should render_template('show') }
        it { should render_with_layout('no_sidebar') }
      end

      context "is not related at all with the join request" do
        it {
          sign_in(FactoryGirl.create(:user))
          expect {
            get :show, space_id: space.to_param, id: jr
          }.to raise_error(CanCan::AccessDenied)
        }
      end
    end

    context "an anonymous user with no permission to access the join request" do
      before {
        expect {
          get :show, space_id: space.to_param, id: jr
        }.not_to raise_error
      }
      it { redirect_to login_path }
    end
  end

  describe "#create" do
    let(:user) { FactoryGirl.create(:user) }
    let(:space) { FactoryGirl.create(:space) }
    let(:jr) { FactoryGirl.build(:join_request, candidate: user, introducer: nil, role: nil) }

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
      it { JoinRequest.last.role_id.should eq(JoinRequest.default_role.id) }
      it { JoinRequest.last.request_type.should eql(JoinRequest::TYPES[:request]) }
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
      it { JoinRequest.last.role_id.should eq(JoinRequest.default_role.id) }
      it { JoinRequest.last.request_type.should eql(JoinRequest::TYPES[:request]) }
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

      before {
        jr_attributes.stub(:permit).and_return(jr_attributes)
        controller.stub(:params).and_return(params)
        sign_in(user)
      }

      context "for a user creating a request" do
        let(:jr_allowed_params) {
          [ :comment ]
        }
        before(:each) {
          post :create, space_id: space.to_param, join_request: jr_attributes
        }
        it { jr_attributes.should have_received(:permit).at_least(:once).with(*jr_allowed_params) }
      end

      context "for a space admin creating an invitation" do
        let(:jr_allowed_params) {
          [ :role_id, :comment ]
        }
        before(:each) {
          space.add_member! user, "Admin"
          post :create, space_id: space.to_param, join_request: jr_attributes
        }
        it { jr_attributes.should have_received(:permit).at_least(:once).with(*jr_allowed_params) }
      end
    end
  end

  describe "#create?type=invite" do
    let(:space) { FactoryGirl.create(:space) }
    let(:user) { FactoryGirl.create(:user) }
    let(:candidate) { FactoryGirl.create(:user) }
    let!(:role) { Role.find_by(name: 'User', stage_type: 'Space') }
    before(:each) {
      space.add_member!(user, 'Admin')
      sign_in(user)
    }

    it { should_authorize an_instance_of(JoinRequest), :create, space_id: space.to_param, via: :post }

    context "admin succesfully invites one user" do
      let(:attributes) {
        { join_request: FactoryGirl.attributes_for(:join_request, email: nil, role_id: role.id),
          candidates: candidate.id,
          type: 'invite'
        }
      }

      before(:each) {
        expect {
          post :create, { space_id: space.to_param}.merge(attributes)
        }.to change{space.pending_invitations.count}.by(1)
      }

      it { should redirect_to(invite_space_join_requests_path(space)) }
      it { should set_the_flash.to(I18n.t('join_requests.create.sent', :users => candidate.username)) }
      it { JoinRequest.last.comment.should eql(attributes[:join_request][:comment]) }
      it { JoinRequest.last.introducer.should eql(user) }
      it { JoinRequest.last.candidate.should eql(candidate) }
      it { JoinRequest.last.group.should eql(space) }
      it { JoinRequest.last.role.should eql(role.name) }
      it { JoinRequest.last.request_type.should eql(JoinRequest::TYPES[:invite]) }
    end

    context "admin successfully invites more than one user" do
      let(:candidate2) { FactoryGirl.create(:user) }
      let(:attributes) {
        { join_request: FactoryGirl.attributes_for(:join_request, email: nil, role_id: role.id),
          candidates: "#{candidate.id},#{candidate2.id}",
          type: 'invite'
        }
      }

      before(:each) {
        expect {
          post :create, { space_id: space.to_param}.merge(attributes)
        }.to change{space.pending_invitations.count}.by(2)
      }

      it { should redirect_to(invite_space_join_requests_path(space)) }
      it { should set_the_flash.to(I18n.t('join_requests.create.sent', :users => "#{candidate.username}, #{candidate2.username}")) }
    end

    context "admin successfully invites a user and fails to invite another" do
      let(:candidate2) { user } # is invalid because he's already a member
      let!(:errors) { I18n.t('join_requests.create.already_a_member', :name => candidate2.username) }
      let(:attributes) {
        { join_request: FactoryGirl.attributes_for(:join_request, email: nil, role_id: role.id),
          candidates: "#{candidate.id},#{candidate2.id}",
          type: 'invite'
        }
      }

      before(:each) {
        expect {
          post :create, { space_id: space.to_param}.merge(attributes)
        }.to change{space.pending_invitations.count}.by(1)
      }

      it { should redirect_to(invite_space_join_requests_path(space)) }
      it { should set_the_flash.to(I18n.t('join_requests.create.sent', :users => candidate.username)) }
      it { should set_the_flash.to(I18n.t('join_requests.create.error',
                                          :errors => errors)) }
    end

    context "admin fails to invite a user" do
      let(:candidate) { user } # is invalid because he's already a member
      let!(:errors) { I18n.t('join_requests.create.already_a_member', :name => candidate.username) }
      let(:attributes) {
        { join_request: FactoryGirl.attributes_for(:join_request, email: nil, role_id: role.id),
          candidates: candidate.id,
          type: 'invite'
        }
      }

      before(:each) {
        expect {
          post :create, { space_id: space.to_param }.merge(attributes)
        }.to change{space.pending_invitations.count}.by(0)
      }

      it { should redirect_to(invite_space_join_requests_path(space)) }
      it { should set_the_flash.to(I18n.t('join_requests.create.error', :errors => errors)) }
    end

    context "global admin is not a member of the space and successfully invites one user (RM-1458)" do
      let(:superuser) { FactoryGirl.create(:superuser) }
      before(:each) {
        sign_out user
        sign_in(superuser)
      }

      let(:attributes) {
        {
          join_request: FactoryGirl.attributes_for(:join_request, email: nil, role_id: role.id),
          candidates: candidate.id,
          type: 'invite'
        }
      }

      before(:each) {
        expect {
          post :create, { space_id: space.to_param }.merge(attributes)
        }.to change{space.pending_invitations.count}.by(1)
      }

      it { should redirect_to(invite_space_join_requests_path(space)) }
      it { should set_the_flash.to(I18n.t('join_requests.create.sent', :users => candidate.username)) }
      it { JoinRequest.last.comment.should eql(attributes[:join_request][:comment]) }
      it { JoinRequest.last.introducer.should eql(superuser) }
      it { JoinRequest.last.candidate.should eql(candidate) }
      it { JoinRequest.last.group.should eql(space) }
      it { JoinRequest.last.role.should eql(role.name) }
      it { JoinRequest.last.request_type.should eql(JoinRequest::TYPES[:invite]) }
    end
  end

  describe "#invite" do
    let(:space) { FactoryGirl.create(:space_with_associations) }
    let(:user) { FactoryGirl.create(:user) }

    it { should_authorize space, :invite, :space_id => space.to_param }

    context "if the user is not a member of the space" do
      before(:each) {
        sign_in(user)
      }
      it {
        expect {
          get :invite, :space_id => space.to_param
        }.to raise_error(CanCan::AccessDenied)
      }
    end

    context "if the user is a member of the space, but not an admin" do
      before(:each) {
        space.add_member!(user)
        sign_in(user)
      }
      it {
        expect {
          get :invite, :space_id => space.to_param
        }.to raise_error(CanCan::AccessDenied)
      }
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

  describe "#accept" do
    let(:space) { FactoryGirl.create(:space) }
    let!(:jr) { FactoryGirl.create(:join_request, group: space, introducer: nil) }

    it { should_authorize an_instance_of(JoinRequest), :accept, via: :post, space_id: space.to_param, id: jr }

    context "a space admin" do
      let(:role) { Role.find_by(name: 'Admin', stage_type: 'Space') }
      let(:user) { FactoryGirl.create(:user) }

      before(:each) {
        request.env['HTTP_REFERER'] = "/back"
        space.add_member!(user, 'Admin')
        sign_in(user)
      }

      context "accepts a user request" do
        before(:each) {
          expect {
            post :accept, space_id: space.to_param, id: jr, join_request: { role_id: role.id }
          }.to change{ space.pending_join_requests.count }.by(-1)
          jr.reload
        }

        it { should redirect_to("/back") }
        it { space.users.should include(jr.candidate) }
        it { jr.should be_accepted }
        it { jr.should be_processed }
        it { jr.introducer.should eq(user) }
        it { should set_the_flash.to(I18n.t('join_requests.accept.accepted')) }
      end

      context "accepts a user request with a role" do
        before(:each) {
          expect {
            post :accept, space_id: space.to_param, id: jr, join_request: { role_id: role.id }
          }.to change{ space.pending_join_requests.count }.by(-1)
          jr.reload
        }

        it { jr.role.should eq(role.name) }
      end

      context "creates a recent activity" do
        before(:each) {
          expect {
            post :accept, space_id: space.to_param, id: jr, join_request: { role_id: role.id }
          }.to change{ RecentActivity.count }.by(1)
          jr.reload
        }

        it { RecentActivity.last.trackable.should eq(jr.group) }
        it { RecentActivity.last.owner.should eq(jr) }
        it { RecentActivity.last.recipient.should eq(jr.candidate) }
        it { RecentActivity.last.parameters[:username].should eq(jr.candidate.name) }
      end

      context "accepting a request that was already accepted" do
        let!(:jr) { FactoryGirl.create(:join_request, group: space, accepted: true, processed_at: Time.now) }
        before(:each) {
          @introducer_before = jr.introducer
          @processed_at_before = jr.processed_at
          expect {
            post :accept, space_id: space.to_param, id: jr, join_request: { role_id: role.id }
          }.not_to change{ space.pending_join_requests.count } || change{ RecentActivity.count }
          jr.reload
        }

        it { should redirect_to(space_path(space)) }
        it { jr.should be_accepted }
        it { jr.processed_at.to_i.should eql(@processed_at_before.to_i) }
        it { jr.introducer.should eql(@introducer_before) }
      end

      context "when there's an error saving the request" do
        before(:each) {
          JoinRequest.any_instance.should_receive(:save).and_return(false)
          errors = ActiveModel::Errors.new(jr)
          errors.add(:accepted, "Error 1")
          errors.add(:processed_at, "Error 2")
          JoinRequest.any_instance.stub(:errors).and_return(errors)
          post :accept, space_id: space.to_param, id: jr, join_request: { role_id: role.id }
        }

        it { should redirect_to("/back") }
        it { space.users.should_not include(jr.candidate) }
        it { jr.accepted.should be_nil }
        it { jr.processed_at.should be_nil }
        it { should set_the_flash.to("Accepted Error 1, Processed at Error 2") }
      end

      context "accepts a user request from the join request's show view" do
        before(:each) {
          request.env['HTTP_REFERER'] = space_join_request_path(space, jr)
          expect {
            post :accept, space_id: space.to_param, id: jr, join_request: { role_id: role.id }
          }.to change{ space.pending_join_requests.count }.by(-1)
          jr.reload
        }

        it { should redirect_to(space_join_requests_path(space)) }
      end

      # to be extra sure admins can't accept invitations they sent
      context "accepting an invitation he sent" do
        let!(:jr) { FactoryGirl.create(:join_request_invite, group: space) }
        it {
          expect {
            post :accept, space_id: space.to_param, id: jr
          }.to raise_error{ CanCan::AccessDenied }
        }
      end
    end

    context "an invited user" do
      let(:candidate) { FactoryGirl.create(:user) }
      let!(:jr) { FactoryGirl.create(:space_join_request_invite, group: space, candidate: candidate) }
      before(:each) {
        request.env['HTTP_REFERER'] = "/back"
        sign_in(jr.candidate)
      }

      context "accepts an invite" do
        before(:each) {
          expect {
            post :accept, space_id: space.to_param, id: jr
          }.to change{ space.pending_invitations.count }.by(-1)
          jr.reload
        }
        it { should redirect_to(space_path(space)) }
        it { jr.should be_accepted }
        it { jr.should be_processed }
        it { should set_the_flash.to(I18n.t('join_requests.accept.accepted')) }
      end

      context "accepts an invite with a role" do
        let(:role) { Role.find_by(name: 'Admin', stage_type: 'Space') }
        before(:each) {
          expect {
            post :accept, space_id: space.to_param, id: jr, join_request: { role_id: role.id }
          }.to change{ space.pending_invitations.count }.by(-1)
          jr.reload
        }

        # users should not be able to set the role here
        it { jr.role.should_not eq(role.name) }
      end

      context "accepts an invite with the correct admin assigned role" do
        let(:role) { Role.find_by(name: 'Admin', stage_type: 'Space') }
        before(:each) {
          jr.update_attributes(role_id: role.id)
          expect {
            post :accept, space_id: space.to_param, id: jr, join_request: {}
          }.to change{ space.pending_invitations.count }.by(-1)
          jr.reload
        }

        it { jr.role.should eq(role.name) }
      end

      context "creates a recent activity" do
        before(:each) {
          expect {
            post :accept, space_id: space.to_param, id: jr
          }.to change{ RecentActivity.count }.by(1)
          jr.reload
        }

        it { RecentActivity.last.trackable.should eq(jr.group) }
        it { RecentActivity.last.owner.should eq(jr) }
        it { RecentActivity.last.recipient.should eq(jr.candidate) }
        it { RecentActivity.last.parameters[:username].should eq(jr.candidate.name) }
      end

      context "accepting a request that was already accepted" do
        let!(:jr) { FactoryGirl.create(:space_join_request_invite, group: space, candidate: candidate,
                                       accepted: true, processed_at: Time.now) }
        before(:each) {
          @introducer_before = jr.introducer
          @processed_at_before = jr.processed_at
          expect {
            post :accept, space_id: space.to_param, id: jr
          }.not_to change{ space.pending_join_requests.count } || change{ RecentActivity.count }
          jr.reload
        }

        it { should redirect_to(space_path(space)) }
        it { jr.should be_accepted }
        it { jr.processed_at.to_i.should eql(@processed_at_before.to_i) }
        it { jr.introducer.should eql(@introducer_before) }
      end

      context "when there's an error saving the request" do
        before(:each) {
          JoinRequest.any_instance.should_receive(:save).and_return(false)
          errors = ActiveModel::Errors.new(jr)
          errors.add(:accepted, "Error 1")
          errors.add(:processed_at, "Error 2")
          JoinRequest.any_instance.stub(:errors).and_return(errors)
          post :accept, space_id: space.to_param, id: jr
        }

        it { should redirect_to("/back") }
        it { space.users.should_not include(jr.candidate) }
        it { jr.accepted.should be_nil }
        it { jr.processed_at.should be_nil }
        it { should set_the_flash.to("Accepted Error 1, Processed at Error 2") }
      end
    end
  end

  describe "#decline" do
    let(:space) { FactoryGirl.create(:space) }
    let!(:jr) { FactoryGirl.create(:join_request, group: space, introducer: nil) }

    it { should_authorize an_instance_of(JoinRequest), :decline, via: :post, space_id: space.to_param, id: jr }

    context "a space admin" do
      let(:user) { FactoryGirl.create(:user) }

      before(:each) {
        request.env['HTTP_REFERER'] = "/back"
        space.add_member!(user, 'Admin')
        sign_in(user)
      }

      context "declines a user request" do
        before(:each) {
          expect {
            post :decline, space_id: space.to_param, id: jr
          }.to change{ space.pending_join_requests.count }.by(-1)
          jr.reload
        }

        it { should redirect_to("/back") }
        it { space.users.should_not include(jr.candidate) }
        it { jr.should_not be_accepted }
        it { jr.should be_processed }
        it { jr.introducer.should eq(user) }
        it { should set_the_flash.to(I18n.t('join_requests.decline.declined')) }
      end

      context "creates a recent activity" do
        before(:each) {
          expect {
            post :decline, space_id: space.to_param, id: jr
          }.to change{ RecentActivity.count }.by(1)
          jr.reload
        }

        it { RecentActivity.last.trackable.should eq(jr.group) }
        it { RecentActivity.last.owner.should eq(jr) }
        it { RecentActivity.last.recipient.should eq(jr.candidate) }
        it { RecentActivity.last.parameters[:username].should eq(jr.candidate.name) }
      end

      context "declining a request that was already declined" do
        let!(:jr) { FactoryGirl.create(:join_request, group: space, introducer: nil,
                                       accepted: false, processed_at: Time.now) }
        before(:each) {
          @introducer_before = jr.introducer
          @processed_at_before = jr.processed_at
          expect {
            expect {
              post :decline, space_id: space.to_param, id: jr
            }.to raise_error(ActiveRecord::RecordNotFound)
          }.not_to change{ space.pending_join_requests.count }
          jr.reload
        }

        it { jr.should_not be_accepted }
        it { jr.processed_at.to_i.should eql(@processed_at_before.to_i) }
        it { jr.introducer.should eql(@introducer_before) }
      end

      context "when there's an error saving the request" do
        before(:each) {
          JoinRequest.any_instance.should_receive(:save).and_return(false)
          errors = ActiveModel::Errors.new(jr)
          errors.add(:accepted, "Error 1")
          errors.add(:processed_at, "Error 2")
          JoinRequest.any_instance.stub(:errors).and_return(errors)
          post :decline, space_id: space.to_param, id: jr
        }

        it { should redirect_to("/back") }
        it { space.users.should_not include(jr.candidate) }
        it { jr.accepted.should be_nil }
        it { jr.processed_at.should be_nil }
        it { should set_the_flash.to("Accepted Error 1, Processed at Error 2") }
      end

      context "declines a user request from the join request's show view" do
        before(:each) {
          request.env['HTTP_REFERER'] = space_join_request_path(space, jr)
          expect {
            post :decline, space_id: space.to_param, id: jr
          }.to change{ space.pending_join_requests.count }.by(-1)
          jr.reload
        }

        it { should redirect_to(space_join_requests_path(space)) }
      end

      context "declines an invitation he (or another admin) sent" do
        let!(:jr) { FactoryGirl.create(:space_join_request_invite, group: space) }
        before(:each) {
          expect {
            post :decline, space_id: space.to_param, id: jr
          }.to change{ space.pending_invitations.count }.by(-1) && change{ JoinRequest.count }.by(-1)
        }
        it { should redirect_to(space_join_requests_path(space)) }
        it { JoinRequest.exists?(jr.id).should be(false) }
        it { should set_the_flash.to(I18n.t('join_requests.decline.invitation_destroyed')) }
      end
    end

    context "an invited user" do
      let(:candidate) { FactoryGirl.create(:user) }
      let!(:jr) { FactoryGirl.create(:space_join_request_invite, group: space, candidate: candidate) }
      before(:each) {
        request.env['HTTP_REFERER'] = "/back"
        sign_in(jr.candidate)
      }

      context "declines the invitation" do
        before(:each) {
          expect {
            post :decline, space_id: space.to_param, id: jr
          }.to change{ space.pending_invitations.count }.by(-1)
          jr.reload
        }
        it { should redirect_to(my_home_path) }
        it { jr.should_not be_accepted }
        it { jr.should be_processed }
        it { should set_the_flash.to(I18n.t('join_requests.decline.declined')) }
      end

      context "creates a recent activity" do
        before(:each) {
          expect {
            post :decline, space_id: space.to_param, id: jr
          }.to change{ RecentActivity.count }.by(1)
          jr.reload
        }

        it { RecentActivity.last.trackable.should eq(jr.group) }
        it { RecentActivity.last.owner.should eq(jr) }
        it { RecentActivity.last.recipient.should eq(jr.candidate) }
        it { RecentActivity.last.parameters[:username].should eq(jr.candidate.name) }
      end

      context "declining a request that was already declined" do
        let!(:jr) { FactoryGirl.create(:space_join_request_invite, group: space, candidate: candidate,
                                       accepted: false, processed_at: Time.now) }
        before(:each) {
          @introducer_before = jr.introducer
          @processed_at_before = jr.processed_at
          expect {
            expect {
              post :decline, space_id: space.to_param, id: jr
            }.to raise_error(ActiveRecord::RecordNotFound)
          }.not_to change{ space.pending_join_requests.count }
          jr.reload
        }

        it { jr.should_not be_accepted }
        it { jr.processed_at.to_i.should eql(@processed_at_before.to_i) }
        it { jr.introducer.should eql(@introducer_before) }
      end

      context "when there's an error saving the request" do
        before(:each) {
          JoinRequest.any_instance.should_receive(:save).and_return(false)
          errors = ActiveModel::Errors.new(jr)
          errors.add(:accepted, "Error 1")
          errors.add(:processed_at, "Error 2")
          JoinRequest.any_instance.stub(:errors).and_return(errors)
          post :decline, space_id: space.to_param, id: jr
        }

        it { should redirect_to("/back") }
        it { space.users.should_not include(jr.candidate) }
        it { jr.accepted.should be_nil }
        it { jr.processed_at.should be_nil }
        it { should set_the_flash.to("Accepted Error 1, Processed at Error 2") }
      end

      context "declines a request he made" do
        let!(:jr) { FactoryGirl.create(:space_join_request, group: space, candidate: candidate) }
        before(:each) {
          expect {
            post :decline, space_id: space.to_param, id: jr
          }.to change{ space.pending_invitations.count }.by(-1) && change{ JoinRequest.count }.by(-1)
        }
        it { should redirect_to(my_home_path) }
        it { JoinRequest.exists?(jr.id).should be(false) }
        it { should set_the_flash.to(I18n.t('join_requests.decline.request_destroyed')) }
      end
    end
  end
end
