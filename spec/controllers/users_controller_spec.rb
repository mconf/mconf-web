# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe UsersController do
  render_views

  let!(:referer) { "http://#{Site.current.domain}" }
  before { request.env["HTTP_REFERER"] = referer }

  it "includes Mconf::ApprovalControllerModule"

  describe "#index" do
    let(:space) { FactoryGirl.create(:space_with_associations, public: true) }

    # TODO: how to test nested authorization? might have to adapt should_authorize
    skip { should_authorize Space, :show }
    skip { should_authorize User, :index, space_id: space.to_param }

    it "should paginate users (10 per page)"

    context "loads the space" do
      before { get :index, space_id: space.to_param }
      it { should assign_to(:space).with(space) }
    end

    context "loads the webconference room information" do
      before { get :index, space_id: space.to_param }
      it { should assign_to(:webconf_room).with(space.bigbluebutton_room) }
    end

    context "sets @users to all users in the space ordered by name" do
      before do
        @users = [
          FactoryGirl.create(:user, _full_name: 'Dio'),
          FactoryGirl.create(:user, _full_name: 'Opeth'),
          FactoryGirl.create(:user, _full_name: 'A Perfect Circle')
        ]

        @users.each { |user| space.add_member!(user) }

        get :index, space_id: space.to_param
      end

      it { should assign_to(:users).with([@users[2], @users[0], @users[1]]) }
    end

    context "renders users/index" do
      before { get :index, space_id: space.to_param }

      it { should render_template('index') }
      it { should render_with_layout('spaces_show') }
    end

    context "with a private space" do
      before { space.update_attributes(public: false) }

      context 'redirect to login path for a logged out user' do
        before { get :index, space_id: space.to_param }

        it { should redirect_to(login_path) }
      end

      context 'deny access to logged in non-member' do
        let(:user) { FactoryGirl.create(:user) }
        before {
          sign_in(user)
        }

        it { expect{get :index, space_id: space.to_param}.to raise_error(CanCan::AccessDenied) }
      end

      context 'show users for logged in member' do
        let(:user) { FactoryGirl.create(:user) }
        before {
          sign_in(user)
          space.add_member!(user)

          get :index, space_id: space.to_param
        }

        it { should render_template('index') }
      end

    end

  end

  describe "#show" do
    it "should display a 404 for inexisting users" do
      expect {
        get :show, id: "inexisting_user"
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "should display a 404 for empty username" do
      expect {
        get :show, id: ""
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "should return OK status for existing user" do
      get :show, id: FactoryGirl.create(:superuser).to_param
      response.response_code.should == 200
    end

    it { should_authorize an_instance_of(User), :show, id: FactoryGirl.create(:user).to_param }

    # TODO: lot's of cases here (profile visibility settings * types of users )
    # (anon, logged in, fellow, private fellow, admin, user itself)
    context "assigns the correct @recent_activities" do
      let(:user) { FactoryGirl.create(:user) }
      let(:public_space) { FactoryGirl.create(:space_with_associations, public: true) }
      let(:private_space) { FactoryGirl.create(:space_with_associations, public: false) }
      before {
        public_space.add_member!(user)
        private_space.add_member!(user)
        @activities = [
          public_space.new_activity(:join, user),
          private_space.new_activity(:join, user),
          private_space.new_activity(:update, user),
        ]
      }

      context 'the user himself' do
        before {
          sign_in(user)
          get :show, id: user.to_param
        }

        it { assigns(:recent_activities).count.should be(3) }
        it { assigns(:recent_activities).should include(RecentActivity.find_by(id: @activities[0])) }
        it { assigns(:recent_activities).should include(RecentActivity.find_by(id: @activities[1])) }
        it { assigns(:recent_activities).should include(RecentActivity.find_by(id: @activities[2])) }
      end

      context 'a user belonging to both spaces' do
        before {
          user2 = FactoryGirl.create(:user)
          public_space.add_member!(user2)
          private_space.add_member!(user2)
          sign_in(user2)
          get :show, id: user.to_param
        }

        it { assigns(:recent_activities).count.should be(3) }
        it { assigns(:recent_activities).should include(RecentActivity.find_by(id: @activities[0])) }
        it { assigns(:recent_activities).should include(RecentActivity.find_by(id: @activities[1])) }
        it { assigns(:recent_activities).should include(RecentActivity.find_by(id: @activities[2])) }
      end

      context 'a user belonging to the private space only' do
        before {
          user2 = FactoryGirl.create(:user)
          private_space.add_member!(user2)
          sign_in(user2)
          get :show, id: user.to_param
        }

        it { assigns(:recent_activities).count.should be(3) }
        it { assigns(:recent_activities).should include(RecentActivity.find_by(id: @activities[0])) }
        it { assigns(:recent_activities).should include(RecentActivity.find_by(id: @activities[1])) }
        it { assigns(:recent_activities).should include(RecentActivity.find_by(id: @activities[2])) }
      end

      context 'a user not belonging to any space' do
        before {
          user2 = FactoryGirl.create(:user)
          sign_in(user2)
          get :show, id: user.to_param
        }

        it { assigns(:recent_activities).count.should be(1) }
        it { assigns(:recent_activities).should include(RecentActivity.find_by(id: @activities[0])) }
      end

      context 'a logged out user' do
        before {
          get :show, id: user.to_param
        }

        it { assigns(:recent_activities).count.should be(1) }
        it { assigns(:recent_activities).should include(RecentActivity.find_by(id: @activities[0])) }
      end
    end
  end

  describe "#edit" do
    let(:user) { FactoryGirl.create(:user) }

    it { should_authorize an_instance_of(User), :edit, id: user.to_param }

    context "template and layout" do
      before(:each) { sign_in(user) }
      before(:each) { get :edit, id: user.to_param }
      it { should render_template('edit') }
      it { should render_with_layout('no_sidebar') }
    end

    context "if the user is editing himself" do
      before {
        Mconf::Shibboleth.any_instance.should_receive(:get_identity_provider).and_return('idp')
      }
      before(:each) {
        sign_in(user)
        get :edit, id: user.to_param
      }
      it { should assign_to(:shib_provider).with('idp') }
    end

    context "an admin editing another user" do
      before {
        Mconf::Shibboleth.any_instance.should_not_receive(:get_identity_provider)
      }
      before(:each) {
        sign_in(FactoryGirl.create(:superuser))
        get :edit, id: user.to_param
      }
      it { should_not assign_to(:shib_provider) }
    end

    context "an anonymous user trying to edit another user" do
      before {
        expect {
          get :edit, id: user.to_param
          user.reload
        }.not_to change { user }
      }
      it { should redirect_to login_path }
    end
  end

  describe "#update" do
    it { should_authorize an_instance_of(User), :update, via: :post, id: FactoryGirl.create(:user).to_param, user: {} }

    context "params_handling" do
      let(:user) { FactoryGirl.create(:user) }
      let(:user_attributes) { FactoryGirl.attributes_for(:user) }
      let(:params) {
        {
          id: user.to_param,
          controller: "users",
          action: "update",
          user: user_attributes
        }
      }

      let(:user_allowed_params) {
        [ :remember_me, :login, :timezone, :receive_digest, :expanded_post,
          :password, :password_confirmation, :current_password ]
      }
      before {
        sign_in(user)
        user_attributes.stub(:permit).and_return(user_attributes)
        controller.stub(:params).and_return(params)
      }
      before(:each) { put :update, id: user.to_param, user: user_attributes }
      it { user_attributes.should have_received(:permit).with(*user_allowed_params) }
    end

    context "attributes that the user can't update" do
      context "trying to update username" do
        before(:each) do
          @user = FactoryGirl.create(:user)
          sign_in @user

          @old_username = @user.username
          @new_username = FactoryGirl.generate(:username)

          put :update, id: @user.to_param, user: { username: @new_username }
        end

        it { response.status.should == 302 }
        it { response.should redirect_to edit_user_path(@user) }
        it { @user.username.should_not == @new_username }
        it { @user.username.should == @old_username }
      end

      context "trying to update email" do
        let(:old_email) { FactoryGirl.generate(:email) }
        let(:user) { FactoryGirl.create(:user, email: old_email) }
        let(:new_email) { FactoryGirl.generate(:email) }

        before(:each) do
          sign_in user

          put :update, id: user.to_param, user: { email: new_email }
          user.reload
        end

        it { response.status.should == 302 }
        it { response.should redirect_to edit_user_path(user) }
        it { user.email.should_not eq(new_email) }
        it { user.email.should eq(old_email) }
      end

      context "trying to update admin flag" do
        context "when normal user" do
          let(:user) { FactoryGirl.create(:user, superuser: false) }

          before(:each) do
            sign_in user

            put :update, id: user.to_param, user: { superuser: true }
            user.reload
          end

          it { response.status.should == 302 }
          it { response.should redirect_to edit_user_path(user) }
          it { user.superuser.should be(false) }
        end

        context "when admin and target is self" do
          let(:user) { FactoryGirl.create(:user, superuser: true) }

          before(:each) do
            sign_in user

            put :update, id: user.to_param, user: { superuser: false }
            user.reload
          end

          it { response.status.should == 302 }
          it { response.should redirect_to edit_user_path(user) }
          it { user.superuser.should be(true) }
        end

        context "when admin and target is another normal user" do
          let(:user) { FactoryGirl.create(:user, superuser: true) }
          let(:user2) { FactoryGirl.create(:user) }

          before(:each) do
            sign_in user

            put :update, id: user2.to_param, user: { superuser: true }
            user2.reload
          end

          it { response.status.should == 302 }
          it { response.should redirect_to edit_user_path(user2) }
          it { user2.superuser.should be(true) }
        end

        context "when admin and target is another admin" do
          let(:user) { FactoryGirl.create(:user, superuser: true) }
          let(:user2) { FactoryGirl.create(:user, superuser: true) }

          before(:each) do
            sign_in user

            put :update, id: user2.to_param, user: { superuser: false }
            user2.reload
          end

          it { response.status.should == 302 }
          it { response.should redirect_to edit_user_path(user2) }
          it { user2.superuser.should be(false) }
        end
      end

      context "trying to update disabled flag" do
        context "when normal user" do
          let(:user) { FactoryGirl.create(:user, disabled: false) }

          before(:each) do
            sign_in user

            put :update, id: user.to_param, user: { disabled: true }
            user.reload
          end

          it { response.status.should == 302 }
          it { response.should redirect_to edit_user_path(user) }
          it { user.disabled.should be(false) }

        end
      end

      context "trying to update can_record flag" do
        context "when normal user" do
          let(:user) { FactoryGirl.create(:user, can_record: true) }

          before(:each) do
            sign_in user

            put :update, id: user.to_param, user: { can_record: false }
            user.reload
          end

          it { response.status.should == 302 }
          it { response.should redirect_to edit_user_path(user) }
          it { user.can_record.should be(true) }
        end
      end

      context "trying to update approved flag" do
        context "when normal user" do
          let(:user) { FactoryGirl.create(:user, approved: true) }

          before(:each) do
            sign_in user

            put :update, id: user.to_param, user: { approved: false }
            user.reload
          end

          it { response.status.should == 302 }
          it { response.should redirect_to edit_user_path(user) }
          it { user.approved.should be(true) }
        end
      end
    end

    context "attributes that the user can update" do
      context "trying to update timezone" do
        let(:old_tz) { "Mountain Time (US & Canada)" }
        let(:user) { FactoryGirl.create(:user, timezone: old_tz) }
        let(:new_tz) { "Dublin" }

        before(:each) do
          sign_in user

          put :update, id: user.to_param, user: { timezone: new_tz }
          user.reload
        end

        it { response.status.should == 302 }
        it { response.should redirect_to edit_user_path(user) }
        it { user.timezone.should_not eq(old_tz) }
        it { user.timezone.should eq(new_tz) }
      end

      context "trying to update password" do
        context "when local authentication is enabled" do
          let(:admin) { FactoryGirl.create(:superuser) }
          before { Site.current.update_attributes(local_auth_enabled: true) }

          context "and is a user editing his own password" do
            before(:each) do
              @user = FactoryGirl.create(:user, password: "foobar", password_confirmation: "foobar")
              sign_in @user

              @old_encrypted = @user.encrypted_password
              @new_pass = "newpass"

              put :update, id: @user.to_param, user: { password: @new_pass, password_confirmation: @new_pass, current_password: "foobar" }
              @user.reload
            end

            it { response.status.should == 302 }
            it { should set_flash.to(I18n.t('user.updated')) }
            it { response.should redirect_to edit_user_path(@user) }
            it { @user.encrypted_password.should_not == @old_encrypted }
          end

          context "and is a user editing his own password and no current password is informed" do
            before(:each) do
              @user = FactoryGirl.create(:user, password: "foobar", password_confirmation: "foobar")
              sign_in @user

              @old_encrypted = @user.encrypted_password
              @new_pass = "newpass"

              put :update, id: @user.to_param, user: { password: @new_pass, password_confirmation: @new_pass }
              @user.reload
            end

            it { response.status.should == 200 }
            it { should render_template(:edit) }
            it { @user.encrypted_password.should == @old_encrypted }
          end

          context "and is a admin editing a user password" do
            before(:each) do
              @user = FactoryGirl.create(:user)
              sign_in admin

              @old_encrypted = @user.encrypted_password
              @new_pass = "newpass"

              put :update, id: @user.to_param, user: { password: @new_pass, password_confirmation: @new_pass }
              @user.reload
            end

            it { response.status.should == 302 }
            it { should set_flash.to(I18n.t('user.updated')) }
            it { response.should redirect_to edit_user_path(@user) }
            it { @user.encrypted_password.should_not == @old_encrypted }
          end

          context "and is a admin editing his own password" do
            let(:admin) { FactoryGirl.create(:superuser, email: "valid@mconf.org") }
            before(:each) do
              @user = admin
              sign_in admin

              @old_encrypted = @user.encrypted_password
              @new_pass = "newpass"

              put :update, id: @user.to_param, user: { password: @new_pass, password_confirmation: @new_pass }
              @user.reload
            end

            it { response.status.should == 302 }
            it { should set_flash.to(I18n.t('user.updated')) }
            it { response.should redirect_to edit_user_path(@user) }
            it { @user.encrypted_password.should_not == @old_encrypted }
          end
        end

        context "when local authentication is disabled" do
          before { Site.current.update_attributes(local_auth_enabled: false)}
          before(:each) do
            @user = FactoryGirl.create(:user, password: "foobar", password_confirmation: "foobar")
            sign_in @user

            @old_encrypted = @user.encrypted_password
            @new_pass = "newpass"

            put :update, id: @user.to_param, user: { password: @new_pass, password_confirmation: @new_pass, current_password: "foobar" }
            @user = User.find_by_username(@user.username)
          end

          it { response.status.should == 302 }
          it { should set_flash.to(I18n.t('user.updated')) }
          it { response.should redirect_to edit_user_path(@user) }
          it { @user.encrypted_password.should == @old_encrypted }
        end
      end
    end

    context "as anonymous user" do
      let!(:old_val) { User::RECEIVE_DIGEST_NEVER } # it could be any other attribute
      let(:user) { FactoryGirl.create(:user, receive_digest: old_val) }
      let!(:new_val) { User::RECEIVE_DIGEST_DAILY }
      before {
        expect {
          put :update, id: user.to_param, user: { receive_digest: new_val }
          user.reload
        }.not_to change { user }
      }
      it { user.receive_digest.should eql(old_val) }
      it { should redirect_to login_path }
    end
  end

  describe "#destroy" do
    let!(:user) { FactoryGirl.create(:user) }
    subject { delete :destroy, id: user.to_param }

    context "superusers can destroy users" do
      before { sign_in(FactoryGirl.create(:superuser)) }

      it { expect { subject }.to change(User, :count).by(-1) }
      it { should redirect_to(manage_users_path) }
    end

    context "a user can't destroy himself" do
      before { sign_in(user) }
      it { expect { subject }.to raise_error(CanCan::AccessDenied) }
    end

    context "a user can't destroy others users" do
      before { sign_in(FactoryGirl.create(:user)) }
      it { expect { subject }.to raise_error(CanCan::AccessDenied) }
    end

    context "as an anonymous user" do
      let!(:user) { FactoryGirl.create(:user) }
      before {
        expect {
          delete :disable, id: user.to_param
        }.not_to change { User.count }
      }
      it { should redirect_to login_path }
    end

    context "destroying a user should destroy all its dependencies" do
      let(:admin) { FactoryGirl.create(:superuser) }
      let(:space) { FactoryGirl.create(:space) }

      before do
        space.add_member!(user)
        sign_in(admin)
      end

      it('removes the profile') { expect { subject }.to change(Profile, :count).by(-1) }
      it('removes the room') { expect { subject }.to change(BigbluebuttonRoom, :count).by(-1) }
      it('removes the permissions') { expect { subject }.to change(Permission, :count).by(-1) }

      context 'removes the LDAP Token' do
        let!(:ldap_token) { FactoryGirl.create(:ldap_token, user: user) }
        it { expect { subject }.to change(LdapToken, :count).by(-1) }
      end

      context 'removes the Shib Token' do
        let!(:ldap_token) { FactoryGirl.create(:shib_token, user: user) }
        it { expect { subject }.to change(ShibToken, :count).by(-1) }
      end

      context 'removes the join requests' do
        let(:space2) { FactoryGirl.create(:space) }
        let!(:space_join_request) { FactoryGirl.create(:join_request_invite, candidate: user) }
        let!(:space_join_request_invite) { FactoryGirl.create(:join_request_invite, candidate: user, group: space2) }
        it { expect { subject }.to change(JoinRequest, :count).by(-2) }
      end

      context "doesn't remove the invitations the user sent" do
        let!(:join_request_invite) { FactoryGirl.create(:join_request_invite, introducer: user) }
        it { expect { subject }.not_to change(JoinRequest, :count) }
      end

      context "doesn't remove the posts" do
        let!(:post) { FactoryGirl.create(:post, author: user, space: space) }
        it { expect { subject }.not_to change(Post, :count) }
      end
    end

    context "destroying a disabled user" do
      let!(:user) { FactoryGirl.create(:user, disabled: true) }
      let(:admin) { FactoryGirl.create(:superuser) }
      before { sign_in(admin) }

      it {
        delete :destroy, id: user.to_param
        User.find_by(id: user.id).should be_nil
        # can't use `change(User, :count)` because #count doesn't consider disabled users
      }
    end

    it { should_authorize an_instance_of(User), :destroy, via: :delete, id: user.to_param }
  end

  describe "#disable" do
    let(:user) { FactoryGirl.create(:user) }

    context "an admin disabling a user" do
      before(:each) { sign_in(FactoryGirl.create(:superuser)) }
      before(:each) { delete :disable, id: user.to_param }
      it { should respond_with(:redirect) }
      it { should set_flash.to(I18n.t('flash.users.disable.notice', username: user.username)) }
      it { should redirect_to(manage_users_path) }
      it("disables the user") { user.reload.disabled.should be(true) }
    end

    context "the user disabling himself" do
      before(:each) { sign_in(user) }
      before(:each) { delete :disable, id: user.to_param }
      it { should respond_with(:redirect) }
      it { should set_flash.to(I18n.t('devise.registrations.destroyed')) }
      it { should redirect_to(root_path) }
      it("disables the user") { user.reload.disabled.should be(true) }
    end

    context "as an anonymous user" do
      let!(:user) { FactoryGirl.create(:user) }
      before {
        expect {
          delete :disable, id: user.to_param
        }.not_to change { User.count }
      }
      it { should redirect_to login_path }
    end

    context "calls User#disable" do
      before do
        sign_in(FactoryGirl.create(:superuser))
        User.any_instance.should_receive(:disable)
      end
      it { delete :disable, id: user.to_param }
    end

    it { should_authorize an_instance_of(User), :disable, via: :delete, id: user.to_param }
  end

  describe "#enable" do
    let(:referer) { manage_users_path }
    before(:each) {
      login_as(FactoryGirl.create(:superuser))
    }

    context "loads the user by username" do
      let(:user) { FactoryGirl.create(:user) }
      before(:each) { post :enable, id: user.to_param }
      it { assigns(:user).should eql(user) }
    end

    context "loads also users that are disabled" do
      let(:user) { FactoryGirl.create(:user, disabled: true) }
      before(:each) { post :enable, id: user.to_param }
      it { assigns(:user).should eql(user) }
    end

    context "if the user is already enabled" do
      let(:user) { FactoryGirl.create(:user, disabled: false) }
      before(:each) { post :enable, id: user.to_param }
      it { should redirect_to(manage_users_path) }
      it { should set_flash.to(I18n.t('flash.users.enable.failure', name: user.name)) }
    end

    context "if the user is disabled" do
      let(:user) { FactoryGirl.create(:user, disabled: true) }
      before(:each) { post :enable, id: user.to_param }
      it { should redirect_to(manage_users_path) }
      it { should set_flash.to(I18n.t('flash.users.enable.notice')) }
      it { user.reload.disabled.should be_falsey }
    end

    it { should_authorize an_instance_of(User), :enable, id: FactoryGirl.create(:user).to_param }
  end

  describe "#select" do
    context ".json" do
      before { User.destroy_all } # exclude seeded user(s)

      context "when the logged is user is an admin show full user data" do
        let(:user) { FactoryGirl.create(:user, superuser: true) }
        before(:each) { login_as(user) }

        let(:expected) {
          @users.map do |u|
            { id: u.id, username: u.username, name: u.name, email: u.email,
              text: "#{u.name} (#{u.username}, #{u.email})" }
          end
        }

        before do
          10.times { FactoryGirl.create(:user) }
          @users = User.joins(:profile).order("profiles.full_name").first(5)
        end
        before(:each) { get :select, format: :json }
        it { should respond_with(:success) }
        it { should respond_with_content_type(:json) }
        it { should assign_to(:users).with(@users) }
        it { response.body.should == expected.to_json }
      end

      context "when there's a user logged" do
        let(:user) { FactoryGirl.create(:superuser) }
        before(:each) { login_as(user) }

        let(:expected) {
          @users.map do |u|
            { id: u.id, username: u.username, name: u.name, email: u.email,
              text: "#{u.name} (#{u.username}, #{u.email})" }
          end
        }

        context "works" do
          before do
            10.times { FactoryGirl.create(:user) }
            @users = User.joins(:profile).order("profiles.full_name").first(5)
          end
          before(:each) { get :select, format: :json }
          it { should respond_with(:success) }
          it { should respond_with_content_type(:json) }
          it { should assign_to(:users).with(@users) }
          it { response.body.should == expected.to_json }
        end

        context "matches users by name" do
          let!(:unique_str) { "123123456456" }
          before do
            FactoryGirl.create(:user, _full_name: "Yet Another User")
            FactoryGirl.create(:user, _full_name: "Abc de Fgh")
            @users = [FactoryGirl.create(:user, _full_name: "Marcos #{unique_str} Silva")]
          end
          before(:each) { get :select, q: unique_str, format: :json }
          it { should assign_to(:users).with(@users) }
          it { response.body.should == expected.to_json }
        end

        context "matches users by username" do
          let(:unique_str) { "123123456456" }
          before do
            FactoryGirl.create(:user, username: "Yet-Another-User")
            FactoryGirl.create(:user, username: "Abc-de-Fgh")
            @users = [FactoryGirl.create(:user, username: "Marcos-#{unique_str}-Silva")]
          end
          before(:each) { get :select, q: unique_str, format: :json }
          it { should assign_to(:users).with(@users) }
          it { response.body.should == expected.to_json }
        end

        context "matches users by email if the current user has permission" do
          let(:unique_str) { "123123456456" }
          before do
            FactoryGirl.create(:user, email: "Yet-Another-User@mconf.org")
            FactoryGirl.create(:user, email: "Abc-de-Fgh@mconf.org")
            FactoryGirl.create(:user, email: "Marcos-#{unique_str}@mconf.org") do |u|
              @users = [u]
            end
          end
          before(:each) { get :select, q: unique_str, format: :json }
          it { should assign_to(:users).with(@users) }
          it { response.body.should == expected.to_json }
        end

        context "doesn't match users by email if the current user has no permission" do
          let(:unique_str) { "123123456456" }
          before do
            user.update_attributes(superuser: false)
            FactoryGirl.create(:user, email: "Yet-Another-User@mconf.org")
            FactoryGirl.create(:user, email: "Abc-de-Fgh@mconf.org")
            FactoryGirl.create(:user, email: "Marcos-#{unique_str}@mconf.org")
          end
          before(:each) { get :select, q: unique_str, format: :json }
          it { should assign_to(:users).with([]) }
          it { response.body.should == [].to_json }
        end

        context "has a param to limit the users in the response" do
          before do
            10.times { FactoryGirl.create(:user) }
          end
          before(:each) { get :select, limit: 3, format: :json }
          it { assigns(:users).count.should be(3) }
        end

        context "limits to 5 users by default" do
          before do
            10.times { FactoryGirl.create(:user) }
          end
          before(:each) { get :select, format: :json }
          it { assigns(:users).count.should be(5) }
        end

        context "limits to a maximum of 50 users" do
          before do
            60.times { FactoryGirl.create(:user) }
          end
          before(:each) { get :select, limit: 51, format: :json }
          it { assigns(:users).count.should be(50) }
        end

        context "orders @users by the user's full name" do
          before {
            @u1 = FactoryGirl.create(:user, _full_name: 'Last one')
            @u2 = user
            @u2.profile.update_attributes(full_name: 'Ce user')
            @u3 = FactoryGirl.create(:user, _full_name: 'A user')
            @u4 = FactoryGirl.create(:user, _full_name: 'Be user')
          }
          before(:each) { get :select, format: :json }
          it { assigns(:users).count.should be(4) }
          it("first user") { assigns(:users)[0].should eql(@u3) }
          it("second user") { assigns(:users)[1].should eql(@u4) }
          it("third user") { assigns(:users)[2].should eql(@u2) }
          it("fourth user") { assigns(:users)[3].should eql(@u1) }
        end

        it { should_authorize User, :select }
      end
    end
  end

  describe "#fellows" do
    context ".json" do
      context "when there's a user logged" do
        let(:user) { FactoryGirl.create(:user) }
        before(:each) { login_as(user) }

        let(:expected) {
          @users.map do |u|
            { id: u.id, username: u.username, name: u.name,
              text: "#{u.name} (#{u.username})" }
          end
        }

        context "uses User#fellows" do
          before do
            space = FactoryGirl.create(:space)
            space.add_member! user
            @users = Helpers.create_fellows(2, space)
            subject.current_user.should_receive(:fellows).with(nil, nil).and_return(@users)
          end
          before(:each) { get :fellows, format: :json }
          it { should respond_with(:success) }
          it { should respond_with_content_type(:json) }
          it { should assign_to(:users).with(@users) }
          it { response.body.should == expected.to_json }
        end

        context "filters users by name" do
          before do
            space = FactoryGirl.create(:space)
            space.add_member! user
            @users = Helpers.create_fellows(2, space)
            subject.current_user.should_receive(:fellows).with("test", nil).and_return(@users)
          end
          before(:each) { get :fellows, q: "test", format: :json }
          it { should assign_to(:users).with(@users) }
          it { response.body.should == expected.to_json }
        end

        context "limits the users in the response" do
          before do
            space = FactoryGirl.create(:space)
            space.add_member! user
            @users = Helpers.create_fellows(10, space)
            @users = @users.first(3)
            subject.current_user.should_receive(:fellows).with(nil, 3).and_return(@users)
         end
          before(:each) { get :fellows, limit: 3, format: :json }
          it { should assign_to(:users).with(@users) }
          it { response.body.should == expected.to_json }
        end

        it { should_authorize User, :fellows }
      end
    end
  end

  describe "#current" do
    context ".json" do
      context "when there's a user logged" do
        let(:user) { FactoryGirl.create(:user) }
        before(:each) do
          login_as(user)
          @expected = {
            id: user.id, username: user.username, name: user.name
          }
          get :current, format: :json
        end
        it { should respond_with(:success) }
        it { should respond_with_content_type(:json) }
        it { should assign_to(:user).with(user) }
        it { response.body.should == @expected.to_json }
      end

      context "when there's no user logged" do
        before(:each) { get :current, format: :json }
        it { should respond_with(:success) }
        it { should respond_with_content_type(:json) }
        it { should assign_to(:user).with(nil) }
        it { response.body.should == {}.to_json }
      end
    end

    context ".xml" do
      context "when there's a user logged" do
        let(:user) { FactoryGirl.create(:user) }
        before(:each) do
          login_as(user)
          @expected = {
            id: user.id, username: user.username,
            name: user.name, text: "#{user.name} (#{user.username})"
          }
          get :current, format: :xml
        end
        it { should respond_with(:success) }
        it { should respond_with_content_type(:xml) }
        it { should assign_to(:user).with(user) }
        it {
          assert_select "user" do
            assert_select "id", {count: 1, text: user.id}
            assert_select "username", {count: 1, text: user.username}
            assert_select "name", {count: 1, text: user.name}
          end
        }
      end

      context "when there's no user logged" do
        before(:each) { get :current, format: :xml }
        it { should respond_with(:success) }
        it { should respond_with_content_type(:xml) }
        it { should assign_to(:user).with(nil) }
        it {
          assert_select "user" do
            assert_select "id", false
            assert_select "username", false
            assert_select "name", false
          end
        }
      end

      it { should_authorize User, :current }
    end
  end

  describe "#confirm" do
    let(:user) { FactoryGirl.create(:unconfirmed_user) }
    before {
      login_as(FactoryGirl.create(:superuser))
    }

    context "the action #confirm confirms the user" do
      before(:each) {
        post :confirm, id: user.to_param
      }
      it { should respond_with(:redirect) }
      it { should redirect_to(referer) }
      it ("confirms the user") { user.reload.confirmed?.should be(true) }
    end
  end

  describe "#approve" do
    let(:user) { FactoryGirl.create(:unconfirmed_user, approved: false) }
    let(:admin) { FactoryGirl.create(:superuser) }
    before {
      login_as(admin)
    }

    context "if #require_registration_approval is set in the current site" do
      before(:each) {
        Site.current.update_attributes(require_registration_approval: true)
        post :approve, id: user.to_param
      }
      it { should respond_with(:redirect) }
      it { should set_flash.to(I18n.t('users.approve.approved', name: user.name)) }
      it { should redirect_to(referer) }
      it("approves the user") { user.reload.should be_approved }
      it("confirms the user") { user.reload.should be_confirmed }

      context "skips the confirmation email" do
        let(:user) { FactoryGirl.create(:unconfirmed_user) }
        before(:each) {
          Site.current.update_attributes(require_registration_approval: true)
        }
        it {
          user.confirmed?.should be(false) # just to make sure wasn't already confirmed
          expect {
            post :approve, id: user.to_param
            user.reload.confirmed?.should be(true)
          }.not_to change{ ActionMailer::Base.deliveries }
        }
      end

      context "should create an activity" do
        subject { RecentActivity.where(key: 'user.approved').last }
        it { subject.should_not be_nil }
        it { subject.owner.should eql admin }
        it { subject.trackable.should eql user}
        it { subject.notified.should be_falsey }
      end
    end

    context "if #require_registration_approval is not set in the current site" do
      before(:each) {
        Site.current.update_attributes(require_registration_approval: false)
        post :approve, id: user.to_param
      }
      it { should respond_with(:redirect) }
      it { should set_flash.to(I18n.t('users.approve.not_enabled')) }
      it { should redirect_to(referer) }
      it { user.should be_approved } # auto approved
      it("should not create an activity") { RecentActivity.where(key: 'user.approved').should be_empty }
    end

    it { should_authorize an_instance_of(User), :approve, via: :post, id: user.to_param }
  end

  describe "#disapprove" do
    let(:user) { FactoryGirl.create(:user, approved: true) }
    before {
      login_as(FactoryGirl.create(:superuser))
    }

    context "if #require_registration_approval is set in the current site" do
      before(:each) {
        Site.current.update_attributes(require_registration_approval: true)
        post :disapprove, id: user.to_param
      }
      it { should respond_with(:redirect) }
      it { should set_flash.to(I18n.t('users.disapprove.disapproved', name: user.name)) }
      it { should redirect_to(referer) }
      it("disapproves the user") { user.reload.should_not be_approved }
    end

    context "if #require_registration_approval is not set in the current site" do
      before(:each) {
        Site.current.update_attributes(require_registration_approval: false)
        post :disapprove, id: user.to_param
      }
      it { should respond_with(:redirect) }
      it { should set_flash.to(I18n.t('users.disapprove.not_enabled')) }
      it { should redirect_to(referer) }
      it("user is still (auto) approved") { user.reload.should be_approved } # auto approved on registration
    end

    it { should_authorize an_instance_of(User), :disapprove, via: :post, id: user.to_param }
  end

  describe "#new" do
    # see bug #1719
    context "doesnt store location for redirect from xhr" do
      let(:superuser) { FactoryGirl.create(:superuser) }
      before {
        sign_in superuser
        controller.session[:user_return_to] = "/home"
        controller.session[:previous_user_return_to] = "/manage/users"
        request.env['CONTENT_TYPE'] = "text/html"
        xhr :get, :new
      }
      it { controller.session[:user_return_to].should eq( "/home") }
      it { controller.session[:previous_user_return_to].should eq("/manage/users") }
    end

    context "logged as a superuser" do
      let(:superuser) { FactoryGirl.create(:superuser) }
      before(:each) { sign_in(superuser) }

      context "template and view" do
        before(:each) { get :new }
        it { should render_with_layout("application") }
        it { should render_template("users/new") }
      end

      context "template and view via xhr" do
        before(:each) { xhr :get, :new }
        it { should_not render_with_layout() }
        it { should render_template("users/new") }
      end

      it "assigns @user" do
        get :new
        should assign_to(:user).with(instance_of(User))
      end
    end

    context "logged as a regular user" do
      let(:user) { FactoryGirl.create(:user) }
      before(:each) {
        sign_in(user)
      }
      it {
        expect { get :new }.to raise_error(CanCan::AccessDenied)
      }
    end

    context "as anonymous user" do
      before { get :new }
      it { should redirect_to login_path }
    end
  end

  describe "#create"  do
    describe "as a global admin" do
      let(:superuser) { FactoryGirl.create(:superuser) }
      before { sign_in(superuser) }

      describe "creates a new user with valid attributes" do
        let(:user) { FactoryGirl.build(:user) }
        before(:each) {
          expect {
            post :create, user: {
              email: user.email, _full_name: "Maria Test", username: "maria-test",
              password: "test123", password_confirmation: "test123"
            }
          }.to change(User, :count).by(1)
        }

        it { should set_flash.to(I18n.t('users.create.success')) }
        it { should redirect_to manage_users_path }
        it { User.last.confirmed?.should be true }
        it { User.last.approved?.should be true }
        it('should create the correct user created activity') {
          RecentActivity.where(key: 'user.created', trackable: User.last).should be_empty
          RecentActivity.where(key: 'user.created_by_admin', trackable: User.last).count.should be(1)
        }
        it('should not create an user approved activity') { RecentActivity.where(key: 'user.approved').should be_empty }
      end

      describe "creates a new user with valid attributes and with the ability to record meetings" do
        let(:user) { FactoryGirl.build(:user) }
        before(:each) {
          expect {
            post :create, user: {
              email: user.email, _full_name: "Maria Test", username: "maria-test",
              password: "test123", password_confirmation: "test123", can_record: true
            }
          }.to change(User, :count).by(1)
        }

        it { should set_flash.to(I18n.t('users.create.success')) }
        it { should redirect_to manage_users_path }
        it { User.last.confirmed?.should be true }
        it { User.last.approved?.should be true }
        it { User.last.can_record.should be true }
      end

      describe "creates a new user with invalid attributes" do
        before(:each) {
          expect {
            post :create, user: {
              email: "test@test.com", _full_name: "Maria Test", username: "maria-test",
              password: "test123", password_confirmation: "test1234"
            }
          }.not_to change(User, :count)
        }

        it {
          msg = assigns(:user).errors.full_messages.join(", ")
          should set_flash.to(I18n.t('users.create.error', errors: msg))
        }
        it { should redirect_to manage_users_path }
      end

      # we need this to make sure the users are approved when needed
      describe "when the site requires registration approval" do
        before {
          Site.current.update_attributes(require_registration_approval: true)
        }

        describe "creates a new user with valid attributes" do
          let(:user) { FactoryGirl.build(:user) }
          before {
            expect {
              post :create, user: {
                email: user.email, _full_name: "Maria Test", username: "maria-test",
                password: "test123", password_confirmation: "test123"
              }
            }.to change(User, :count).by(1)
          }

          it { should set_flash.to(I18n.t('users.create.success')) }
          it { should redirect_to manage_users_path }
          it { User.last.confirmed?.should be true }
          it { User.last.approved?.should be true }
          it { User.last.can_record.should_not be true }
          it('should create the correct user created activity') {
            RecentActivity.where(key: 'user.created', trackable: User.last).should be_empty
            RecentActivity.where(key: 'user.created_by_admin', trackable: User.last).count.should be(1)
          }
          it('should create a user approved activity') { RecentActivity.where(key: 'user.approved').should be_empty }
        end

        describe "creates a new user with valid attributes and with the ability to record meetings" do
          let(:user) { FactoryGirl.build(:user) }
          before {
            expect {
              post :create, user: {
                email: user.email, _full_name: "Maria Test", username: "maria-test",
                password: "test123", password_confirmation: "test123", can_record: true
              }
            }.to change(User, :count).by(1)
          }

          it { should set_flash.to(I18n.t('users.create.success')) }
          it { should redirect_to manage_users_path }
          it { User.last.confirmed?.should be true }
          it { User.last.approved?.should be true }
          it { User.last.can_record.should be true }
        end
      end
    end
  end

end
