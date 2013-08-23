# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe UsersController do
  render_views

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
      get :show, :id => FactoryGirl.create(:superuser).username
      response.response_code.should == 200
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
            :id => user.id, :username => user.username, :name => user.name
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

  describe "#select" do
    context ".json" do
      context "when there's a user logged" do
        let(:user) { FactoryGirl.create(:user) }
        before(:each) { login_as(user) }

        let(:expected) {
          @users.map do |u|
            { :id => u.id, :username => u.username, :name => u.name }
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
            @users = User.all.first(3)
          end
          before(:each) { get :select, :limit => 3, :format => :json }
          it { should assign_to(:users).with(@users) }
          it { response.body.should == expected.to_json }
        end

        context "limits to 5 users by default" do
          before do
            10.times { FactoryGirl.create(:user) }
            @users = User.all.first(5)
          end
          before(:each) { get :select, :format => :json }
          it { should assign_to(:users).with(@users) }
          it { response.body.should == expected.to_json }
        end

        context "limits to a maximum of 50 users" do
          before do
            60.times { FactoryGirl.create(:user) }
            @users = User.all.first(50)
          end
          before(:each) { get :select, :limit => 51, :format => :json }
          it { should assign_to(:users).with(@users) }
          it { response.body.should == expected.to_json }
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
            { :id => u.id, :username => u.username, :name => u.name }
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

  describe "abilities" do

    context "for a normal user:" do
      let(:another_user) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user) }
      before(:each) { login_as(user) }

      # On the colletion

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

      [:show, :edit, :edit_bbb_room].each do |action|
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

      [:edit, :edit_bbb_room].each do |action|
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

      [:edit, :edit_bbb_room].each do |action|
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

      [:show, :edit, :edit_bbb_room].each do |action|
        describe "can access ##{action}" do
          let(:do_action) { get action, :id => user }
          it_should_behave_like "it can access an action"
        end
      end

      [:show, :edit, :edit_bbb_room].each do |action|
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
