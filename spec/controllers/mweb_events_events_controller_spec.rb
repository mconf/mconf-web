# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe MwebEvents::EventsController do
  render_views

  describe "#show" do
    routes { MwebEvents::Engine.routes }

    before(:all) { Site.current.update_attributes(events_enabled: true) }

    context "logged as a normal user" do
      let(:user) { FactoryGirl.create(:user) }

      before(:each) { sign_in(user) }

      context "event owner is a disabled space" do
        let(:owner) { FactoryGirl.create(:space) }
        let(:event) { FactoryGirl.create(:event, owner: owner) }

        before { owner.disable }

        it { expect { get :show, id: event.to_param }.to raise_error(ActiveRecord::RecordNotFound) }
      end

      context "event owner is a disabled user" do
        let(:owner) { FactoryGirl.create(:user) }
        let(:event) { FactoryGirl.create(:event, owner: owner) }

        before { owner.disable }

        it { expect { get :show, id: event.to_param }.to raise_error(ActiveRecord::RecordNotFound) }
      end
    end

    context "logged as an admin" do
      let(:admin) { FactoryGirl.create(:superuser) }

      before(:each) { sign_in(admin) }

      context "event owner is a disabled space" do
        let(:owner) { FactoryGirl.create(:space) }
        let(:event) { FactoryGirl.create(:event, owner: owner) }

        before { owner.disable }

        it { expect { get :show, id: event.to_param }.not_to raise_error }
      end

      context "event owner is a disabled user" do
        let(:owner) { FactoryGirl.create(:user) }
        let(:event) { FactoryGirl.create(:event, owner: owner) }

        before { owner.disable }

        it { expect { get :show, id: event.to_param }.not_to raise_error }
      end
    end

  end

  describe "#invite" do
    let(:owner) { FactoryGirl.create(:user) }
    let(:event) { FactoryGirl.create(:event, owner: owner) }

    context "template and layout" do
      context "template" do
        before(:each) { sign_in(owner) }

        context "xhr" do
          before { xhr :get, :invite, id: event.to_param }

          it { should render_template(:invite) }
          it { should_not render_with_layout }
          it { should assign_to(:event).with(event) }
        end

        context "normal request" do
          before { get :invite, id: event.to_param }

          it { should render_template(:invite) }
          it { should render_with_layout('mweb_events/application') }
          it { should assign_to(:event).with(event) }
        end
      end
    end

    context 'authorization' do
      let(:subject) {
        sign_in(logged_user)
        get :invite, id: event.to_param
      }

      context 'should not authorize non managers to invite' do
        let(:logged_user) { FactoryGirl.create(:user) }
        it { expect{subject}.to raise_error(CanCan::AccessDenied) }
      end

      context 'should authorize owner of a space to invite' do
        let(:logged_user) { event.owner }
        it { expect{subject}.not_to raise_error }
      end
    end

    it { should_authorize an_instance_of(MwebEvents::Event), :invite, method: :get, id: event.to_param }
  end

  describe "#send_invitation" do
    let!(:referer) { "/any" }
    let(:event) { FactoryGirl.create(:event, owner: FactoryGirl.create(:user)) }
    let(:users) { [FactoryGirl.create(:user)] }
    let(:title) { 'Title' }
    let(:message) { 'Message' }
    let(:success) { I18n.t('mweb_events.events.send_invitation.success') + ' ' + users.map(&:name).join(', ')}
    let(:error) { I18n.t('mweb_events.events.send_invitation.errors') + ' ' + users.map(&:name).join(', ') }
    before { request.env["HTTP_REFERER"] = referer }

    context "sending the form" do
      let!(:hash) { { users: users.map(&:id).join(','),
         title: title,
         message: message} }
      before {
        sign_in(event.owner)
      }

      context "with correct data" do
        before {
          expect {
            post :send_invitation, invite: hash, id: event.to_param
          }.to change { Invitation.count }.by(1)
        }
        context "with the right type set" do
          it { Invitation.last.class.should be(EventInvitation) }
        end
        it { should redirect_to(referer) }
        it { should set_the_flash.to success }
      end

      context "with more than one user invited" do
        let(:users) { [FactoryGirl.create(:user), FactoryGirl.create(:user)] }
        before {
          expect {
            post :send_invitation, invite: hash, id: event.to_param
          }.to change { Invitation.count }.by(users.length)
        }

        context "with the right type set" do
          it { Invitation.last.class.should be(EventInvitation) }
        end

        it { should redirect_to(referer) }
        it { should set_the_flash.to success }
      end

      context "missing users" do
        before {
          hash.delete(:users)
          expect {
            post :send_invitation, invite: hash, id: event.to_param
          }.not_to change { Invitation.count }
        }
        it { should redirect_to(referer) }
        it { should set_the_flash.to I18n.t('mweb_events.events.send_invitation.blank_users') }
      end

      context "missing the title" do
        let(:title) { nil }
        before {
          expect {
            post :send_invitation, invite: hash, id: event.to_param
          }.not_to change { Invitation.count }
        }
        it { should redirect_to(referer) }
        it { should set_the_flash.to I18n.t('mweb_events.events.send_invitation.error_title') }
      end

      context "missing the users" do
        let(:users) { [] }
        before {
          expect {
            post :send_invitation, invite: hash, id: event.to_param
          }.not_to change { Invitation.count }
        }
        it { should redirect_to(referer) }
        skip { should set_the_flash.to error }
      end

      context "missing the message" do
        let(:message) { nil }
        before {
          expect {
            post :send_invitation, invite: hash, id: event.to_param
          }.to change { Invitation.count }.by(1)
        }

        context "with the right type set" do
          it { Invitation.last.class.should be(EventInvitation) }
        end

        it { should redirect_to(referer) }
        it { should set_the_flash.to success }
      end
    end

    context 'authorization' do
      let(:subject) {
        sign_in(logged_user)
        post :send_invitation, id: event.to_param, invite: {}
      }

      context 'should not authorize non managers to send invites' do
        let(:logged_user) { FactoryGirl.create(:user) }
        it { expect{subject}.to raise_error(CanCan::AccessDenied) }
      end

      context 'should authorize owner of a space to send invites' do
        let(:logged_user) { event.owner }
        it { expect{subject}.not_to raise_error }
      end
    end

    it { should_authorize an_instance_of(MwebEvents::Event), :send_invitation, id: event.to_param }
  end

  describe 'organizers' do

    describe '#user_permissions' do
      let(:target) { FactoryGirl.create(:event) }
      let(:user) { FactoryGirl.create(:user) }
      let(:user2) { FactoryGirl.create(:user) }
      let(:user3) { FactoryGirl.create(:user) }
      let!(:p1) { target.add_organizer!(user) }
      let!(:p2) { target.add_organizer!(user2) }

      it { should_authorize an_instance_of(MwebEvents::Event), :user_permissions, :id => target.to_param }

      before {
        user.profile.update_attribute(:full_name, 'ABC')
        user2.profile.update_attribute(:full_name, 'BBC')
        user3.profile.update_attribute(:full_name, 'BBB')
      }

      context "layout and view" do
        before(:each) {
          sign_in(user)
          get :user_permissions, :id => target.to_param
        }

        it { should respond_with(:success) }
        it { assigns(:event).should eq(target) }
        it { assigns(:permissions).should eq([p1, p2]) }
        it { should render_template(/user_permissions/) }
      end

      context "xhr" do
        before {
          sign_in(user)
          xhr :get, :user_permissions, id: target.to_param
        }

        it { should_not render_with_layout }
        it { should assign_to(:event).with(target) }
        it { should assign_to(:permissions).with([p1, p2]) }
      end

      context 'as a logged out user' do
        before {
          get :user_permissions, :id => target.to_param
        }

        it { should redirect_to(Rails.application.routes.url_helpers.login_path) }
      end

      context 'as a user without permissions on the event' do
        before {
          sign_in(user3)
          expect {
            get :user_permissions, :id => target.to_param
          }.to raise_error
        }
      end
    end

    describe '#create_permission' do
      let(:target) { FactoryGirl.create(:event) }
      let(:redirect_path) { MwebEvents::Engine.routes.url_helpers.event_participants_path(target) }
      let(:user) { FactoryGirl.create(:user) }
      let(:users) { [ FactoryGirl.create(:user), FactoryGirl.create(:user) ] }
      let(:user_ids) { users.map(&:id) }
      before {
        target.add_organizer!(user)
        sign_in(user)
      }

      context 'create one permission successfully' do
        before {
          expect {
            post :create_permission, id: target.to_param, users: "#{user_ids[0]}"
          }.to change(Permission, :count).by(1) && change{ target.organizers.count }.by(1)
        }

        it { should set_the_flash.to(I18n.t('mweb_events.events.create_permission.success')) }
        it { should redirect_to(redirect_path) }
      end

      context 'create two permissions successfully' do
        before {
          expect {
            post :create_permission, id: target.to_param, users: user_ids.join(',')
          }.to change(Permission, :count).by(2) && change{ target.organizers.count }.by(2)
        }

        it { should set_the_flash.to(I18n.t('mweb_events.events.create_permission.success')) }
        it { should redirect_to(redirect_path) }
      end

      context 'fail to create one permission' do
        before {
          target.add_organizer!(users[1])
          expect {
            post :create_permission, id: target.to_param, users: "#{user_ids[1]}"
          }.to change(Permission, :count).by(0) && change{ target.organizers.count }.by(0)
        }

        it { should set_the_flash.to(I18n.t('mweb_events.events.create_permission.failure', names: users[1].username)) }
        it { should redirect_to(redirect_path) }
      end

      context 'create one successfully and fail to create another' do
        before {
          expect {
            post :create_permission, id: target.to_param, users: "#{user_ids[0]},#{user_ids[0]}"
          }.to change(Permission, :count).by(1) && change{ target.organizers.count }.by(1)
        }

        it { should set_the_flash.to(I18n.t('mweb_events.events.create_permission.failure', names: "#{users[0].username}")) }
        it { should redirect_to(redirect_path) }
      end

    end
  end
end
