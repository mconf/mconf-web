# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe ManageController do

  describe "#users" do
    before { User.destroy_all } # exclude seeded user(s)

    it "should require authentication"

    # see bug #1719
    context "stores location for redirect from xhr" do
      let(:superuser) { FactoryGirl.create(:superuser) }
      let(:user) { FactoryGirl.create(:user) }
      before {
        sign_in superuser
        controller.session[:user_return_to] = "/home"
        request.env['CONTENT_TYPE'] = "text/html"
        xhr :get, :users
      }
      it { controller.session[:user_return_to].should eq("/manage/users") }
      it { controller.session[:previous_user_return_to].should eq("/home") }
    end

    context "authorizes" do
      let(:user) { FactoryGirl.create(:superuser) }
      before(:each) { sign_in(user) }
      it { should_authorize :manage, :spaces }
    end

    describe "if the current user is a superuser" do
      let(:user) { FactoryGirl.create(:superuser) }
      before(:each) { sign_in(user) }

      it {
        get :users
        should respond_with(:success)
      }

      context "sets @users to a list of all users, including disabled users" do
        before {
          @u1 = user
          @u2 = FactoryGirl.create(:user, :disabled => false)
          @u3 = FactoryGirl.create(:user, :disabled => true)
        }
        before(:each) { get :users }
        it { assigns(:users).count.should be(3) }
        it { assigns(:users).should include(@u1) }
        it { assigns(:users).should include(@u2) }
        it { assigns(:users).should include(@u3) }
      end

      it "eager loads user profiles" do
        FactoryGirl.create(:user)
        get :users
        assigns(:users).each do |user|
          user.association(:profile).loaded?.should be_truthy
        end
      end

      context "orders @users by the user's full name" do
        before {
          @u1 = FactoryGirl.create(:user, :_full_name => 'Last one')
          @u2 = user
          @u2.profile.update_attributes(:full_name => 'Ce user')
          @u3 = FactoryGirl.create(:user, :_full_name => 'A user')
          @u4 = FactoryGirl.create(:user, :_full_name => 'Be user')
        }
        before(:each) { get :users }
        it { assigns(:users).count.should be(4) }
        it { assigns(:users)[0].should eql(@u3) }
        it { assigns(:users)[1].should eql(@u4) }
        it { assigns(:users)[2].should eql(@u2) }
        it { assigns(:users)[3].should eql(@u1) }
      end

      context "paginates the list of users" do
        before {
          45.times { FactoryGirl.create(:user) }
        }

        context "if no page is passed in params" do
          before(:each) { get :users }
          it { assigns(:users).size.should be(20) }
          it { controller.params[:page].should be_nil }
        end

        context "if a page is passed in params" do
          before(:each) { get :users, :page => 2 }
          it { assigns(:users).size.should be(20) }
          it("includes the correct users in @users") {
            page = User.joins(:profile).order("profiles.full_name").paginate(:page => 2, :per_page => 20)
            page.each do |user|
              assigns(:users).should include(user)
            end
          }
          it { controller.params[:page].should eql("2") }
        end
      end

      context "use params[:q] to filter the results" do

        context "by full name" do
          before {
            @u1 = User.first
            @u1.profile.update_attributes(:full_name => 'First')
            @u2 = user
            @u2.profile.update_attributes(:full_name => 'Second')
            @u3 = FactoryGirl.create(:user, :_full_name => 'Secondary')
          }
          before(:each) { get :users, :q => 'second' }
          it { assigns(:users).count.should be(2) }
          it { assigns(:users).should include(@u2) }
          it { assigns(:users).should include(@u3) }
        end

        context "by username" do
          before {
            @u1 = FactoryGirl.create(:user, :username => 'First')
            @u2 = user
            @u2.update_attributes(:username => 'Second')
            @u3 = FactoryGirl.create(:user, :username => 'Secondary')
          }
          before(:each) { get :users, :q => 'second' }
          it { assigns(:users).count.should be(2) }
          it { assigns(:users).should include(@u2) }
          it { assigns(:users).should include(@u3) }
        end

        context "by email" do
          before {
            @u1 = FactoryGirl.create(:user, :email => 'first@here.com')
            @u2 = FactoryGirl.create(:user, :email => 'second@there.com')
            @u3 = FactoryGirl.create(:user, :email => 'my@secondary.org')
          }
          before(:each) { get :users, :q => 'second' }
          it { assigns(:users).count.should be(2) }
          it { assigns(:users).should include(@u2) }
          it { assigns(:users).should include(@u3) }
        end

      end

      context "use params [:admin, :approved, :disabled, :can_record] to filter the results" do
        let!(:users) {[
          FactoryGirl.create(:user, username: 'el-magron'),
          FactoryGirl.create(:superuser, username: 'el-admin'),
          FactoryGirl.create(:user, username: 'el-debilitado', disabled: true),
          FactoryGirl.create(:user, username: 'reprovado'),
          FactoryGirl.create(:user, username: 'remembrador', can_record: true),
          User.first # the original admin user
        ]}
        before {
          users[3].disapprove!
          get :users, params
        }

        context "no params" do
          let(:params) { {} }

          it { assigns(:users).count.should be(6) }
          it { assigns(:users).should include(*users) }
        end

        context "params[:admin]" do
          context 'is true' do
            let(:params) { {admin: 'true'} }
            it { assigns(:users).count.should be(2) }
            it { assigns(:users).should include(users[1], users[5]) }
          end

          context 'is false' do
            let(:params) { {admin: 'false'} }
            it { assigns(:users).count.should be(4) }
            it { assigns(:users).should include(users[0], users[2], users[3], users[4]) }
          end
        end

        context "params[:approved]" do
          context 'is true' do
            let(:params) { {approved: 'true'} }
            it { assigns(:users).count.should be(5) }
            it { assigns(:users).should include(users[0], users[1], users[2], users[4], users[5]) }
          end

          context 'is false' do
            let(:params) { {approved: 'false'} }
            it { assigns(:users).count.should be(1) }
            it { assigns(:users).should include(users[3]) }
          end
        end

        context "params[:disabled]" do
          context 'is true' do
            let(:params) { {disabled: 'true'} }
            it { assigns(:users).count.should be(1) }
            it { assigns(:users).should include(users[2]) }
          end

          context 'is false' do
            let(:params) { {disabled: 'false'} }
            it { assigns(:users).count.should be(5) }
            it { assigns(:users).should include(users[0], users[1], users[3], users[4], users[5]) }
          end
        end

        context "params[:can_record]" do
          context 'is true' do
            let(:params) { {can_record: 'true'} }
            it { assigns(:users).count.should be(1) }
            it { assigns(:users).should include(users[4]) }
          end

          context 'is false' do
            let(:params) { {can_record: 'false'} }
            it { assigns(:users).count.should be(5) }
            it { assigns(:users).should include(users[0], users[1], users[2], users[3], users[5]) }
          end
        end

        context "mixed params" do
          let(:params) { {admin: 'false', approved: 'true', q: 'el re'} }

          it { assigns(:users).count.should be(3) }
          it { assigns(:users).should include(users[0], users[2], users[4]) }
        end
      end

      context "if xhr request" do
        before(:each) { xhr :get, :users }
        it { should render_template('manage/_users_list') }
        it { should_not render_with_layout }
      end

      context "not xhr request" do
        before(:each) { get :users }
        it { should render_template(:users) }
        it { should render_with_layout('no_sidebar') }
      end
    end
  end

  describe "#spaces" do
    it "should require authentication"

    context "authorizes" do
      let(:user) { FactoryGirl.create(:superuser) }
      before(:each) { sign_in(user) }
      it { should_authorize :manage, :spaces }
    end

    describe "if the current user is a superuser" do
      let(:user) { FactoryGirl.create(:superuser) }
      before(:each) { sign_in(user) }

      it {
        get :spaces
        should respond_with(:success)
      }

      context "sets @spaces to a list of all spaces, including disabled spaces" do
        before {
          @s1 = FactoryGirl.create(:space, :disabled => false)
          @s2 = FactoryGirl.create(:space, :disabled => false)
          @s3 = FactoryGirl.create(:space, :disabled => true)
        }
        before(:each) { get :spaces }
        it { assigns(:spaces).count.should be(3) }
        it { assigns(:spaces).should include(@s1) }
        it { assigns(:spaces).should include(@s2) }
        it { assigns(:spaces).should include(@s3) }
      end

      context "orders @spaces by name" do
        before {
          @s1 = FactoryGirl.create(:space, :name => 'Last one')
          @s2 = FactoryGirl.create(:space, :name => 'Ce space')
          @s3 = FactoryGirl.create(:space, :name => 'A space')
          @s4 = FactoryGirl.create(:space, :name => 'Be space')
        }
        before(:each) { get :spaces }
        it { assigns(:spaces).count.should be(4) }
        it { assigns(:spaces)[0].should eql(@s3) }
        it { assigns(:spaces)[1].should eql(@s4) }
        it { assigns(:spaces)[2].should eql(@s2) }
        it { assigns(:spaces)[3].should eql(@s1) }
      end

      context "paginates the list of spaces" do
        before {
          45.times { FactoryGirl.create(:space) }
        }

        context "if no page is passed in params" do
          before(:each) { get :spaces }
          it { assigns(:spaces).size.should be(20) }
          it { controller.params[:page].should be_nil }
        end

        context "if a page is passed in params" do
          before(:each) { get :spaces, :page => 2 }
          it { assigns(:spaces).size.should be(20) }
          it("includes the correct spaces in @spaces") {
            page = Space.order('name').paginate(:page => 2, :per_page => 20)
            page.each do |space|
              assigns(:spaces).should include(space)
            end
          }
          it { controller.params[:page].should eql("2") }
        end
      end

      context "use params[:q] to filter the results" do
        context "by name" do
          before {
            @s1 = FactoryGirl.create(:space, :name => 'First')
            @s2 = FactoryGirl.create(:space, :name => 'Second')
            @s3 = FactoryGirl.create(:space, :name => 'Secondary')
          }
          before(:each) { get :spaces, :q => 'sec' }
          it { assigns(:spaces).count.should be(2) }
          it { assigns(:spaces).should include(@s2) }
          it { assigns(:spaces).should include(@s3) }
        end
      end

      context "if xhr request" do
        before(:each) { xhr :get, :spaces }
        it { should render_template('manage/_spaces_list') }
        it { should_not render_with_layout }
      end

      context "not xhr request" do
        before(:each) { get :spaces }
        it { should render_template(:spaces) }
        it { should render_with_layout('no_sidebar') }
      end
    end
  end

  describe "abilities", :abilities => true do
    render_views(false)

    context "for a superuser", :user => "superuser" do
      let(:user) { FactoryGirl.create(:superuser) }
      before(:each) { login_as(user) }
      it { should allow_access_to(:users) }
      it { should allow_access_to(:spaces) }
    end

    context "for a normal user", :user => "normal" do
      let(:user) { FactoryGirl.create(:user) }
      before(:each) { login_as(user) }
      it { should_not allow_access_to(:users) }
      it { should_not allow_access_to(:spaces) }
    end

    context "for an anonymous user", :user => "anonymous" do
      it { should_not allow_access_to(:users) }
      it { should_not allow_access_to(:spaces) }
    end
  end

end
