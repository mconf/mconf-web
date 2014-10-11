# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe UsersController do
  render_views

  describe "#index" do
    it "loads the space"
    it "loads the webconference room information"
    it "sets @users to all users in the space ordered by name"
    it "renders users/index"
    it "renders with the layout spaces_show"

    # TODO: how to test nested authorization? might have to adapt should_authorize
    # it { should_authorize Space, :index }
    # it { should_authorize User, :index }
  end

  describe "#show" do
    it "should display a 404 for inexisting users" do
      get :show, :id => "inexisting_user"
      response.response_code.should == 404
    end

    it "should display a 404 for empty username" do
      get :show, :id => ""
      response.response_code.should == 404
    end

    it "should return OK status for existing user" do
      get :show, :id => FactoryGirl.create(:superuser).to_param
      response.response_code.should == 200
    end

    it { should_authorize an_instance_of(User), :show, :id => FactoryGirl.create(:user).to_param }
  end

  describe "#edit" do
    let(:user) { FactoryGirl.create(:user) }

    it { should_authorize an_instance_of(User), :edit, :id => user.to_param }

    context "template and layout" do
      before(:each) { sign_in(user) }
      before(:each) { get :edit, :id => user.to_param }
      it { should render_template('edit') }
      it { should render_with_layout('no_sidebar') }
    end

    context "if the user is editing himself" do
      before {
        Mconf::Shibboleth.any_instance.should_receive(:get_identity_provider).and_return('idp')
      }
      before(:each) {
        sign_in(user)
        get :edit, :id => user.to_param
      }
      it { should assign_to(:shib_provider).with('idp') }
    end

    context "an admin editing another user" do
      before {
        Mconf::Shibboleth.any_instance.should_not_receive(:get_identity_provider)
      }
      before(:each) {
        sign_in(FactoryGirl.create(:superuser))
        get :edit, :id => user.to_param
      }
      it { should_not assign_to(:shib_provider) }
    end
  end

  describe "#update" do
    it { should_authorize an_instance_of(User), :update, :via => :post, :id => FactoryGirl.create(:user).to_param, :user => {} }

    context "params_handling" do
      let(:user) { FactoryGirl.create(:user) }
      let(:user_attributes) { FactoryGirl.attributes_for(:user) }
      let(:params) {
        {
          :id => user.to_param,
          :controller => "users",
          :action => "update",
          :user => user_attributes
        }
      }

      let(:user_allowed_params) {
        [ :password, :password_confirmation, :remember_me, :current_password, :login,
          :approved, :disabled, :timezone, :can_record, :receive_digest, :notification, :expanded_post ]
      }
      before {
        sign_in(user)
        user_attributes.stub(:permit).and_return(user_attributes)
        controller.stub(:params).and_return(params)
      }
      before(:each) { put :update, :id => user.to_param, :user => user_attributes }
      it { user_attributes.should have_received(:permit).with(*user_allowed_params) }
    end

    context "attributes that the user can't update" do
      context "trying to update username" do
        before(:each) do
          @user = FactoryGirl.create(:user)
          sign_in @user

          @old_username = @user.username
          @new_username = FactoryGirl.generate(:username)

          put :update, :id => @user.to_param, :user => { :username => @new_username }
        end

        it { response.status.should == 302 }
        it { response.should redirect_to edit_user_path(@user) }
        it { @user.username.should_not == @new_username }
        it { @user.username.should == @old_username }
      end

      context "trying to update email" do
        let(:old_email) { FactoryGirl.generate(:email) }
        let(:user) { FactoryGirl.create(:user, :email => old_email) }
        let(:new_email) { FactoryGirl.generate(:email) }

        before(:each) do
          sign_in user

          put :update, :id => user.to_param, :user => { :email => new_email }
          user.reload
        end

        it { response.status.should == 302 }
        it { response.should redirect_to edit_user_path(user) }
        it { user.email.should_not eq(new_email) }
        it { user.email.should eq(old_email) }
      end

      context "trying to update admin flag" do
        context "when normal user" do
          let(:user) { FactoryGirl.create(:user, :superuser => false) }

          before(:each) do
            sign_in user

            put :update, :id => user.to_param, :user => { :superuser => true }
            user.reload
          end

          it { response.status.should == 302 }
          it { response.should redirect_to edit_user_path(user) }
          it { user.superuser.should be(false) }

        end

        context "when admin and target is self" do
          let(:user) { FactoryGirl.create(:user, :superuser => true) }

          before(:each) do
            sign_in user

            put :update, :id => user.to_param, :user => { :superuser => false }
            user.reload
          end

          it { response.status.should == 302 }
          it { response.should redirect_to edit_user_path(user) }
          it { user.superuser.should be(true) }
        end

        context "when admin and target is another normal user" do
          let(:user) { FactoryGirl.create(:user, :superuser => true) }
          let(:user2) { FactoryGirl.create(:user) }

          before(:each) do
            sign_in user

            put :update, :id => user2.to_param, :user => { :superuser => true }
            user2.reload
          end

          it { response.status.should == 302 }
          it { response.should redirect_to edit_user_path(user2) }
          it { user2.superuser.should be(true) }
        end

        context "when admin and target is another admin" do
          let(:user) { FactoryGirl.create(:user, :superuser => true) }
          let(:user2) { FactoryGirl.create(:user, :superuser => true) }

          before(:each) do
            sign_in user

            put :update, :id => user2.to_param, :user => { :superuser => false }
            user2.reload
          end

          it { response.status.should == 302 }
          it { response.should redirect_to edit_user_path(user2) }
          it { user2.superuser.should be(false) }
        end
      end

    end

    context "attributes that the user can update" do
      context "trying to update timezone" do
        let(:old_tz) { "Mountain Time (US & Canada)" }
        let(:user) { FactoryGirl.create(:user, :timezone => old_tz) }
        let(:new_tz) { "Dublin" }

        before(:each) do
          sign_in user

          put :update, :id => user.to_param, :user => { :timezone => new_tz }
          user.reload
        end

        it { response.status.should == 302 }
        it { response.should redirect_to edit_user_path(user) }
        it { user.timezone.should_not eq(old_tz) }
        it { user.timezone.should eq(new_tz) }
      end

      context "trying to update notifications" do
        let!(:old_not) { User::NOTIFICATION_VIA_EMAIL }
        let(:user) { FactoryGirl.create(:user, :notification => old_not) }
        let!(:new_not) { User::NOTIFICATION_VIA_PM }

        before(:each) do
          sign_in user

          put :update, :id => user.to_param, :user => { :notification => new_not }
          user.reload
        end

        it { response.status.should == 302 }
        it { response.should redirect_to edit_user_path(user) }
        it { user.notification.should_not eq(old_not) }
        it { user.notification.should eq(new_not) }
      end

      context "trying to update password" do
        context "when local authentication is enabled" do
          before { Site.current.update_attributes(local_auth_enabled: true)}
          before(:each) do
            @user = FactoryGirl.create(:user, :password => "foobar", :password_confirmation => "foobar")
            sign_in @user

            @old_encrypted = @user.encrypted_password
            @new_pass = "newpass"

            put :update, :id => @user.to_param, :user => { :password => @new_pass, :password_confirmation => @new_pass, :current_password => "foobar" }
            @user = User.find_by_username(@user.username)
          end

          it { response.status.should == 302 }
          it { should set_the_flash.to(I18n.t('user.updated')) }
          it { response.should redirect_to edit_user_path(@user) }
          it { @user.encrypted_password.should_not == @old_encrypted }
        end

        context "when local authentication is disabled" do
          before { Site.current.update_attributes(local_auth_enabled: false)}
          before(:each) do
            @user = FactoryGirl.create(:user, :password => "foobar", :password_confirmation => "foobar")
            sign_in @user

            @old_encrypted = @user.encrypted_password
            @new_pass = "newpass"

            put :update, :id => @user.to_param, :user => { :password => @new_pass, :password_confirmation => @new_pass, :current_password => "foobar" }
            @user = User.find_by_username(@user.username)
          end

          it { response.status.should == 302 }
          it { should set_the_flash.to(I18n.t('user.updated')) }
          it { response.should redirect_to edit_user_path(@user) }
          it { @user.encrypted_password.should == @old_encrypted }
        end
      end

    end
  end

  describe "#destroy" do
    let(:user) { FactoryGirl.create(:user) }

    context "an admin removing a user" do
      before(:each) { sign_in(FactoryGirl.create(:superuser)) }
      before(:each) { delete :destroy, :id => user.to_param }
      it { should respond_with(:redirect) }
      it { should set_the_flash.to(I18n.t('user.disabled', :username => user.username)) }
      it { should redirect_to(manage_users_path) }
      it("disables the user") { user.reload.disabled.should be_truthy }
    end

    context "the user removing himself" do
      before(:each) { sign_in(user) }
      before(:each) { delete :destroy, :id => user.to_param }
      it { should respond_with(:redirect) }
      it { should set_the_flash.to(I18n.t('devise.registrations.destroyed')) }
      it { should redirect_to(root_path) }
      it("disables the user") { user.reload.disabled.should be_truthy }
    end

    it { should_authorize an_instance_of(User), :destroy, :via => :delete, :id => user.to_param }
  end

  describe "#enable" do
    before(:each) { login_as(FactoryGirl.create(:superuser)) }

    context "loads the user by username" do
      let(:user) { FactoryGirl.create(:user) }
      before(:each) { post :enable, :id => user.to_param }
      it { assigns(:user).should eql(user) }
    end

    context "loads also users that are disabled" do
      let(:user) { FactoryGirl.create(:user, :disabled => true) }
      before(:each) { post :enable, :id => user.to_param }
      it { assigns(:user).should eql(user) }
    end

    context "if the user is already enabled" do
      let(:user) { FactoryGirl.create(:user, :disabled => false) }
      before(:each) { post :enable, :id => user.to_param }
      it { should redirect_to(manage_users_path) }
      it { should set_the_flash.to(I18n.t('user.error.enabled', :name => user.username)) }
    end

    context "if the user is disabled" do
      let(:user) { FactoryGirl.create(:user, :disabled => true) }
      before(:each) { post :enable, :id => user.to_param }
      it { should redirect_to(manage_users_path) }
      it { should set_the_flash.to(I18n.t('user.enabled')) }
      it { user.reload.disabled.should be_falsey }
    end

    it { should_authorize an_instance_of(User), :enable, :id => FactoryGirl.create(:user).to_param }
  end

  describe "#select" do
    context ".json" do
      before { User.destroy_all } # exclude seeded user(s)

      context "when there's a user logged" do
        let(:user) { FactoryGirl.create(:user) }
        before(:each) { login_as(user) }

        let(:expected) {
          @users.map do |u|
            { :id => u.id, :username => u.username,
              :name => u.name, :email => u.email,
              :text => "#{u.name} (#{u.username}, #{u.email})" }
          end
        }

        context "works" do
          before do
            10.times { FactoryGirl.create(:user) }
            @users = User.joins(:profile).order("profiles.full_name").first(5)
          end
          before(:each) { get :select, :format => :json }
          it { should respond_with(:success) }
          it { should respond_with_content_type(:json) }
          it { should assign_to(:users).with(@users) }
          it { response.body.should == expected.to_json }
        end

        context "matches users by name" do
          let!(:unique_str) { "123123456456" }
          before do
            FactoryGirl.create(:user, :_full_name => "Yet Another User")
            FactoryGirl.create(:user, :_full_name => "Abc de Fgh")
            @users = [FactoryGirl.create(:user, :_full_name => "Marcos #{unique_str} Silva")]
          end
          before(:each) { get :select, :q => unique_str, :format => :json }
          it { should assign_to(:users).with(@users) }
          it { response.body.should == expected.to_json }
        end

        context "matches users by username" do
          let(:unique_str) { "123123456456" }
          before do
            FactoryGirl.create(:user, :username => "Yet-Another-User")
            FactoryGirl.create(:user, :username => "Abc-de-Fgh")
            @users = [FactoryGirl.create(:user, :username => "Marcos-#{unique_str}-Silva")]
          end
          before(:each) { get :select, :q => unique_str, :format => :json }
          it { should assign_to(:users).with(@users) }
          it { response.body.should == expected.to_json }
        end

        context "matches users by email" do
          let(:unique_str) { "123123456456" }
          before do
            FactoryGirl.create(:user, :email => "Yet-Another-User@mconf.org")
            FactoryGirl.create(:user, :email => "Abc-de-Fgh@mconf.org")
            FactoryGirl.create(:user, :email => "Marcos-#{unique_str}@mconf.org") do |u|
              @users = [u]
            end
          end
          before(:each) { get :select, :q => unique_str, :format => :json }
          it { should assign_to(:users).with(@users) }
          it { response.body.should == expected.to_json }
        end

        context "has a param to limit the users in the response" do
          before do
            10.times { FactoryGirl.create(:user) }
          end
          before(:each) { get :select, :limit => 3, :format => :json }
          it { assigns(:users).count.should be(3) }
        end

        context "limits to 5 users by default" do
          before do
            10.times { FactoryGirl.create(:user) }
          end
          before(:each) { get :select, :format => :json }
          it { assigns(:users).count.should be(5) }
        end

        context "limits to a maximum of 50 users" do
          before do
            60.times { FactoryGirl.create(:user) }
          end
          before(:each) { get :select, :limit => 51, :format => :json }
          it { assigns(:users).count.should be(50) }
        end

        context "orders @users by the user's full name" do
          before {
            @u1 = FactoryGirl.create(:user, :_full_name => 'Last one')
            @u2 = user
            @u2.profile.update_attributes(:full_name => 'Ce user')
            @u3 = FactoryGirl.create(:user, :_full_name => 'A user')
            @u4 = FactoryGirl.create(:user, :_full_name => 'Be user')
          }
          before(:each) { get :select, :format => :json }
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
            { :id => u.id, :username => u.username,
              :name => u.name, :email => u.email,
              :text => "#{u.name} (#{u.username}, #{u.email})" }
          end
        }

        context "uses User#fellows" do
          before do
            space = FactoryGirl.create(:space)
            space.add_member! user
            @users = Helpers.create_fellows(2, space)
            subject.current_user.should_receive(:fellows).with(nil, nil).and_return(@users)
          end
          before(:each) { get :fellows, :format => :json }
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
          before(:each) { get :fellows, :q => "test", :format => :json }
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
          before(:each) { get :fellows, :limit => 3, :format => :json }
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
            :id => user.id, :username => user.username, :name => user.name
          }
          get :current, :format => :json
        end
        it { should respond_with(:success) }
        it { should respond_with_content_type(:json) }
        it { should assign_to(:user).with(user) }
        it { response.body.should == @expected.to_json }
      end

      context "when there's no user logged" do
        before(:each) { get :current, :format => :json }
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
            :id => user.id, :username => user.username,
            :name => user.name, :text => "#{user.name} (#{user.username})"
          }
          get :current, :format => :xml
        end
        it { should respond_with(:success) }
        it { should respond_with_content_type(:xml) }
        it { should assign_to(:user).with(user) }
        it {
          assert_select "user" do
            assert_select "id", {:count => 1, :text => user.id}
            assert_select "username", {:count => 1, :text => user.username}
            assert_select "name", {:count => 1, :text => user.name}
          end
        }
      end

      context "when there's no user logged" do
        before(:each) { get :current, :format => :xml }
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

  describe "#approve" do
    let(:user) { FactoryGirl.create(:user, :approved => false) }
    before {
      request.env["HTTP_REFERER"] = "/any"
      login_as(FactoryGirl.create(:superuser))
    }

    context "if #require_registration_approval is set in the current site" do
      before(:each) {
        Site.current.update_attributes(:require_registration_approval => true)
        post :approve, :id => user.to_param
      }
      it { should respond_with(:redirect) }
      it { should set_the_flash.to(I18n.t('users.approve.approved', :username => user.username)) }
      it { should redirect_to('/any') }
      it("approves the user") { user.reload.approved?.should be_truthy }
      it("confirms the user") { user.reload.confirmed?.should be_truthy }

      # TODO: To test this we need to create an unconfirmed server with FactoryGirl, but it's triggering
      #   an error related to delayed_job. Test this when delayed_job is removed, see #811.
      # context "skips the confirmation email" do
      #   before(:each) {
      #     Site.current.update_attributes(:require_registration_approval => true)
      #   }
      #   it {
      #     user.confirmed?.should be_falsey # just to make sure wasn't already confirmed
      #     expect {
      #       post :approve, :id => user.to_param
      #     }.not_to change{ ActionMailer::Base.deliveries }
      #     user.confirmed?.should be_truthy
      #   }
      # end
    end

    context "if #require_registration_approval is not set in the current site" do
      before(:each) {
        Site.current.update_attributes(:require_registration_approval => false)
        post :approve, :id => user.to_param
      }
      it { should respond_with(:redirect) }
      it { should set_the_flash.to(I18n.t('users.approve.not_enabled')) }
      it { should redirect_to('/any') }
      it { user.reload.approved?.should be_truthy } # auto approved
    end

    it { should_authorize an_instance_of(User), :approve, :via => :post, :id => user.to_param }
  end

  describe "#disapprove" do
    let(:user) { FactoryGirl.create(:user, :approved => true) }
    before {
      request.env["HTTP_REFERER"] = "/any"
      login_as(FactoryGirl.create(:superuser))
    }

    context "if #require_registration_approval is set in the current site" do
      before(:each) {
        Site.current.update_attributes(:require_registration_approval => true)
        post :disapprove, :id => user.to_param
      }
      it { should respond_with(:redirect) }
      it { should set_the_flash.to(I18n.t('users.disapprove.disapproved', :username => user.username)) }
      it { should redirect_to('/any') }
      it("disapproves the user") { user.reload.approved?.should be_falsey }
    end

    context "if #require_registration_approval is not set in the current site" do
      before(:each) {
        Site.current.update_attributes(:require_registration_approval => false)
        post :disapprove, :id => user.to_param
      }
      it { should respond_with(:redirect) }
      it { should set_the_flash.to(I18n.t('users.disapprove.not_enabled')) }
      it { should redirect_to('/any') }
      it("user is still (auto) approved") { user.reload.approved?.should be_truthy } # auto approved on registration
    end

    it { should_authorize an_instance_of(User), :disapprove, :via => :post, :id => user.to_param }
  end

end
