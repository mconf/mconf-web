# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe UsersController do
  render_views

  describe "#current" do
    context ".json" do
      context "when there's a user logged" do
        login_user

        before(:each) do
          @expected = {
            :id => @user.id, :username => @user.username, :name => @user.name
          }
          get :current, :format => :json
        end
        it { should respond_with(:success) }
        it { should respond_with_content_type(:json) }
        it { should assign_to(:user).with(@user) }
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
        login_user

        before(:each) do
          @expected = {
            :id => @user.id, :username => @user.username, :name => @user.name
          }
          get :current, :format => :xml
        end
        it { should respond_with(:success) }
        it { should respond_with_content_type(:xml) }
        it { should assign_to(:user).with(@user) }
        it {
          assert_select "user" do
            assert_select "id", {:count => 1, :text => @user.id}
            assert_select "username", {:count => 1, :text => @user.username}
            assert_select "name", {:count => 1, :text => @user.name}
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
        login_user
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
        login_user
        let(:expected) {
          @users.map do |u|
            { :id => u.id, :username => u.username, :name => u.name }
          end
        }

        context "uses User#fellows" do
          before do
            space = FactoryGirl.create(:space)
            space.add_member! @user # created by login_user above
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
            space.add_member! @user # created by login_user above
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
            space.add_member! @user # created by login_user above
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

end
