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
  end

  describe "#edit" do
    let(:user) { FactoryGirl.create(:user) }

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
        before(:each) do
          @user = FactoryGirl.create(:user)
          sign_in @user

          @old_email = @user.email
          @new_email = FactoryGirl.generate(:email)

          put :update, :id => @user.to_param, :user => { :email => @new_email }
          @user.reload
        end

        it { response.status.should == 302 }
        it { response.should redirect_to edit_user_path(@user) }
        it { @user.email.should_not == @new_email }
        it { @user.email.should == @old_email }
      end
    end

    context "attributes that the user can update" do
      context "trying to update timezone" do

        before(:each) do
          @user = FactoryGirl.create(:user)
          sign_in @user

          @old_tz = @user.timezone
          @new_tz = FactoryGirl.generate(:timezone)

          put :update, :id => @user.to_param, :user => { :timezone => @new_tz }
          @user.reload
        end

        it { response.status.should == 302 }
        it { response.should redirect_to edit_user_path(@user) }
        it { @user.timezone.should_not == @old_tz }
        it { @user.timezone.should == @new_tz }
      end

      context "trying to update notifications" do

        before(:each) do
          @user = FactoryGirl.create(:user)
          sign_in @user

          @old_not = @user.notification
          @new_not = @user.notification == User::RECEIVE_DIGEST_DAILY ? User::RECEIVE_DIGEST_WEEKLY : User::RECEIVE_DIGEST_DAILY

          put :update, :id => @user.to_param, :user => { :notification => @new_not }
          @user.reload
        end

        it { response.status.should == 302 }
        it { response.should redirect_to edit_user_path(@user) }
        it { @user.notification.should_not == @old_not }
        it { @user.notification.should == @new_not }
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
      it("disables the user") { user.reload.disabled.should be_true }
    end

    context "the user removing himself" do
      before(:each) { sign_in(user) }
      before(:each) { delete :destroy, :id => user.to_param }
      it { should respond_with(:redirect) }
      it { should set_the_flash.to(I18n.t('devise.registrations.destroyed')) }
      it { should redirect_to(root_path) }
      it("disables the user") { user.reload.disabled.should be_true }
    end
  end

  it "#enable"

  describe "#select" do
    context ".json" do
      context "when there's a user logged" do
        let(:user) { FactoryGirl.create(:user) }
        before(:each) { login_as(user) }

        let(:expected) {
          @users.map do |u|
            { :id => u.id, :username => u.username,
              :name => u.name, :text => "#{u.name} (#{u.username})" }
          end
        }

        context "works" do
          before do
            10.times { FactoryGirl.create(:user) }
            @users = User.all.first(5)
          end
          before(:each) { get :select, :format => :json }
          it { should respond_with(:success) }
          it { should respond_with_content_type(:json) }
          it { should assign_to(:users).with(@users) }
          it { response.body.should == expected.to_json }
        end

        context "matches users by name" do
          let(:unique_str) { "123" }
          before do
            FactoryGirl.create(:user, :_full_name => "Yet Another User")
            FactoryGirl.create(:user, :_full_name => "Abc de Fgh")
            FactoryGirl.create(:user, :_full_name => "Marcos #{unique_str} Silva") do |u|
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
              :name => u.name, :text => "#{u.name} (#{u.username})" }
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
      it("approves the user") { user.reload.approved?.should be_true }
      it("confirms the user") { user.reload.confirmed?.should be_true }

      # TODO: To test this we need to create an unconfirmed server with FactoryGirl, but it's triggering
      #   an error related to delayed_job. Test this when delayed_job is removed, see #811.
      # context "skips the confirmation email" do
      #   before(:each) {
      #     Site.current.update_attributes(:require_registration_approval => true)
      #   }
      #   it {
      #     user.confirmed?.should be_false # just to make sure wasn't already confirmed
      #     expect {
      #       post :approve, :id => user.to_param
      #     }.not_to change{ ActionMailer::Base.deliveries }
      #     user.confirmed?.should be_true
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
      it { user.reload.approved?.should be_true } # auto approved
    end
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
      it("disapproves the user") { user.reload.approved?.should be_false }
    end

    context "if #require_registration_approval is not set in the current site" do
      before(:each) {
        Site.current.update_attributes(:require_registration_approval => false)
        post :disapprove, :id => user.to_param
      }
      it { should respond_with(:redirect) }
      it { should set_the_flash.to(I18n.t('users.disapprove.not_enabled')) }
      it { should redirect_to('/any') }
      it("user is still (auto) approved") { user.reload.approved?.should be_true } # auto approved on registration
    end
  end

  describe "abilities", :abilities => true do

    context "for a normal user:" do
      let(:another_user) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user) }
      before(:each) { login_as(user) }

      # On the collection

      describe "can access #index" do
        let(:space) { FactoryGirl.create(:space) }
        before(:each) { get :index, :space_id => space.to_param }
        it { should respond_with(:success) }
      end

      [:current, :select].each do |action|
        describe "can access ##{action}.json" do
          let(:do_action) { get action, :format => :json }
          it_should_behave_like "it can access an action"
        end
      end

      describe "can access #current.xml" do
        let(:do_action) { get :current, :format => :xml }
        it_should_behave_like "it can access an action"
      end

      # On the user himself

      [:show, :edit].each do |action|
        describe "can access ##{action}" do
          let(:do_action) { get action, :id => user }
          it_should_behave_like "it can access an action"
        end
      end

      describe "can access #update" do
        let(:do_action) { post :edit, :id => user }
        it_should_behave_like "it can access an action"
      end

      describe "can access #destroy" do
        let(:do_action) { delete :destroy, :id => user }
        it_should_behave_like "it can access an action"
      end

      [:enable].each do |action|
        describe "cannot access ##{action}" do
          let(:do_action) { post :enable, :id => user }
          it_should_behave_like "it cannot access an action"
        end
      end

      # For other users

      describe "can access #show for other users" do
        let(:do_action) { get :show, :id => another_user }
        it_should_behave_like "it can access an action"
      end

      [:edit].each do |action|
        describe "cannot access ##{action} for other users" do
          let(:do_action) { get action, :id => another_user }
          it_should_behave_like "it cannot access an action"
        end
      end

      [:enable, :update, :destroy].each do |action|
        describe "cannot access ##{action}" do
          let(:do_action) { post action, :id => another_user, :user => {} }
          it_should_behave_like "it cannot access an action"
        end
      end

    end

    context "for an anonymous user:" do
      let(:user) { FactoryGirl.create(:user) }

      describe "can access #index" do
        let(:space) { FactoryGirl.create(:space) }
        let(:do_action) { get :index, :space_id => space }
        it_should_behave_like "it can access an action"
      end

      describe "can access #show" do
        let(:do_action) { get :show, :id => user }
        it_should_behave_like "it can access an action"
      end

      [:edit].each do |action|
        describe "cannot access ##{action}" do
          let(:do_action) { get action, :id => user }
          it_should_behave_like "it cannot access an action"
        end
      end

      [:update, :destroy, :enable].each do |action|
        describe "cannot access ##{action}" do
          let(:do_action) { post action, :id => user }
          it_should_behave_like "it cannot access an action"
        end
      end
    end

    context "for a superuser:" do
      let(:another_user) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:superuser) }
      before(:each) { login_as(user) }

      context "can access #index" do
        let(:space) { FactoryGirl.create(:space) }
        let(:do_action) { get :index, :space_id => space }
        it_should_behave_like "it can access an action"
      end

      [:show, :edit].each do |action|
        describe "can access ##{action}" do
          let(:do_action) { get action, :id => user }
          it_should_behave_like "it can access an action"
        end
      end

      [:show, :edit].each do |action|
        describe "can access ##{action} for other users" do
          let(:do_action) { get action, :id => another_user }
          it_should_behave_like "it can access an action"
        end
      end

      [:update, :destroy, :enable].each do |action|
        describe "can access ##{action}" do
          let(:do_action) { post action, :id => user.to_param, :user => {} }
          it_should_behave_like "it can access an action"
        end
      end

      [:update, :destroy, :enable].each do |action|
        describe "can access ##{action} for other users" do
          let(:do_action) { post action, :id => another_user.to_param, :user => {} }
          it_should_behave_like "it can access an action"
        end
      end
    end

    pending "for a disabled user:"
    pending "for showing public email in profile"

  end

end
