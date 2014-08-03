require 'spec_helper'

describe ManageController do

  describe "#users" do
    before { User.destroy_all } # exclude seeded user(s)

    let(:user) { FactoryGirl.create(:superuser) }
    before(:each) { sign_in(user) }

    it {
      get :users
      should respond_with(:success)
    }

    it { should_authorize :manage, :users }

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
        before(:each) { get :users, :q => 'sec' }
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
        before(:each) { get :users, :q => 'sec' }
        it { assigns(:users).count.should be(2) }
        it { assigns(:users).should include(@u2) }
        it { assigns(:users).should include(@u3) }
      end

      # TODO: This is triggering an error related to delayed_job. Test this when delayed_job
      #   is removed, see #811.
      # context "by email" do
      #   before {
      #     @u1 = User.first # the seeded user
      #     @u1.update_attributes(:email => 'first@here.com')
      #     @u2 = user
      #     @u2.update_attributes(:email => 'second@there.com')
      #     @u3 = FactoryGirl.create(:user, :email => 'my@secondary.org')
      #   }
      #   before(:each) { get :users, :q => 'sec' }
      #   it { assigns(:users).count.should be(2) }
      #   it { assigns(:users).should include(@u2) }
      #   it { assigns(:users).should include(@u3) }
      # end

    end

    context "removes partial from params" do
      before(:each) { get :users, :partial => true }
      it { controller.params.should_not have_key(:partial) }
    end

    context "if params[:partial] is set" do
      before(:each) { get :users, :partial => true }
      it { should render_template('manage/_users_list') }
      it { should_not render_with_layout }
    end

    context "if params[:partial] is not set" do
      before(:each) { get :users }
      it { should render_template(:users) }
      it { should render_with_layout('no_sidebar') }
    end

  end

  describe "#spaces" do
    let(:user) { FactoryGirl.create(:superuser) }
    before(:each) { sign_in(user) }

    it {
      get :spaces
      should respond_with(:success)
    }

    it { should_authorize :manage, :spaces }

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

    context "removes partial from params" do
      before(:each) { get :spaces, :partial => true }
      it { controller.params.should_not have_key(:partial) }
    end

    context "if params[:partial] is set" do
      before(:each) { get :spaces, :partial => true }
      it { should render_template('manage/_spaces_list') }
      it { should_not render_with_layout }
    end

    context "if params[:partial] is not set" do
      before(:each) { get :spaces }
      it { should render_template(:spaces) }
      it { should render_with_layout('no_sidebar') }
    end
  end

  describe "#spam" do
    it "is successful"
    it "sets @spam_events to all events marked as spam"
    it "sets @spam_posts to all posts marked as spam"
    it "renders manage/spam"
    it "renders with the layout no_sidebar"

    it { should_authorize :manage, :spam }
  end

  describe "abilities", :abilities => true do
    render_views(false)

    context "for a superuser", :user => "superuser" do
      let(:user) { FactoryGirl.create(:superuser) }
      before(:each) { login_as(user) }
      it { should allow_access_to(:users) }
      it { should allow_access_to(:spaces) }
      it { should allow_access_to(:spam) }
    end

    context "for a normal user", :user => "normal" do
      let(:user) { FactoryGirl.create(:user) }
      before(:each) { login_as(user) }
      it { should_not allow_access_to(:users) }
      it { should_not allow_access_to(:spaces) }
      it { should_not allow_access_to(:spam) }
    end

    context "for an anonymous user", :user => "anonymous" do
      it { should_not allow_access_to(:users) }
      it { should_not allow_access_to(:spaces) }
      it { should_not allow_access_to(:spam) }
    end
  end

end
