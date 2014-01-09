# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe User do

  it "creates a new instance given valid attributes" do
    FactoryGirl.build(:user).should be_valid
  end

  it { should have_one(:profile).dependent(:destroy) }
  it { should have_one(:bigbluebutton_room).dependent(:destroy) }

  it { should have_and_belong_to_many(:spaces) }

  it { should have_many(:permissions).dependent(:destroy) }
  it { should have_many(:events) }
  it { should have_many(:posts).dependent(:destroy) }
  it { should have_many(:participants).dependent(:destroy) }

  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:username) }

  [ :email, :password, :password_confirmation,
    :remember_me, :login, :username, :receive_digest, :approved ].each do |attribute|
    it { should allow_mass_assignment_of(attribute) }
  end

  describe "#profile" do
    let(:user) { FactoryGirl.create(:user) }

    it "is created when the user is created" do
      user.profile.should_not be_nil
      user.profile.should be_an_instance_of(Profile)
    end
  end

  describe "#bigbluebutton_room" do
    let(:user) { FactoryGirl.create(:user) }
    it { should have_one(:bigbluebutton_room).dependent(:destroy) }
    it { should accept_nested_attributes_for(:bigbluebutton_room) }

    it "is created when the user is created" do
      user.bigbluebutton_room.should_not be_nil
      user.bigbluebutton_room.should be_an_instance_of(BigbluebuttonRoom)
    end

    it "has the user as owner" do
      user.bigbluebutton_room.owner.should be(user)
    end

    it "has param and name equal the user's username" do
      user.bigbluebutton_room.param.should eql(user.username)
      user.bigbluebutton_room.name.should eql(user.username)
    end

    it "has the default logout url" do
      user.bigbluebutton_room.logout_url.should eql("/feedback/webconf/")
    end

    it "has random passwords set" do
      user.bigbluebutton_room.attendee_password.should_not be_blank
      user.bigbluebutton_room.attendee_password.length.should be(8)
      user.bigbluebutton_room.moderator_password.should_not be_blank
      user.bigbluebutton_room.moderator_password.length.should be(8)
    end

    pending "has the server as the first server existent"
  end

  describe "on update" do
    context "updates the webconf room" do
      let(:user) { FactoryGirl.create(:user, :username => "old-user-name") }
      before(:each) { user.update_attributes(:username => "new-user-name") }
      it { user.bigbluebutton_room.param.should be(user.username) }
      it { user.bigbluebutton_room.name.should be(user.username) }
    end
  end

  describe "on create" do
    describe "verify if doesn't exist a space with the same permalink of the username" do
      before(:each) { FactoryGirl.create(:space, :permalink => "test") }
      before(:each) { FactoryGirl.build(:user, :username => "test") }
      it { should_not be_valid }
    end

    describe "#automatically_approve_if_needed" do
      context "if #require_registration_approval is not set in the current site" do
        before { Site.current.update_attributes(:require_registration_approval => false) }

        context "automatically approves the user" do
          before(:each) { @user = FactoryGirl.create(:user, :approved => false) }
          it { @user.approved?.should be_true }
        end
      end

      context "if #require_registration_approval is set in the current site" do
        before { Site.current.update_attributes(:require_registration_approval => true) }

        context "doesn't approve the user" do
          before(:each) { @user = FactoryGirl.create(:user, :approved => false) }
          it { @user.approved?.should be_false }
        end
      end
    end
  end

  describe "#accessible_rooms" do
    let(:user) { FactoryGirl.create(:user) }
    let(:user_room) { FactoryGirl.create(:bigbluebutton_room, :owner => user) }
    let(:private_space_member) { FactoryGirl.create(:private_space) }
    let(:private_space_not_member) { FactoryGirl.create(:private_space) }
    let(:public_space_member) { FactoryGirl.create(:public_space) }
    let(:public_space_not_member) { FactoryGirl.create(:public_space) }
    before do
      user_room
      public_space_not_member
      private_space_member.add_member!(user)
      public_space_member.add_member!(user)
    end

    subject { user.accessible_rooms }
    it { subject.should == subject.uniq }
    it { should include(user_room) }
    it { should include(private_space_member.bigbluebutton_room) }
    it { should include(public_space_member.bigbluebutton_room) }
    it { should include(public_space_not_member.bigbluebutton_room) }
    it { should_not include(private_space_not_member.bigbluebutton_room) }
  end

  describe "#anonymous" do
    subject { user.anonymous? }

    context "for a user in the database" do
      let(:user) { FactoryGirl.create(:user) }
      it { should be_false }
    end

    context "for a user not in the database" do
      let(:user) { FactoryGirl.build(:user) }
      it { should be_true }
    end
  end

  describe "#all_activity" do
    let(:user) { FactoryGirl.create(:user) }

    context "returns the activities in his room" do
      let(:another_user) { FactoryGirl.create(:user) }
      before do
        @activity1 = RecentActivity.create(:owner => user.bigbluebutton_room)
        @activity2 = RecentActivity.create(:owner => another_user.bigbluebutton_room)
      end
      subject { user.all_activity }
      it { subject.length.should be(1) }
      it { subject[0].should eq(@activity1) }
    end

    context "returns the activities in his spaces" do
      let(:space1) { FactoryGirl.create(:space) }
      let(:space2) { FactoryGirl.create(:space) }
      let(:space3) { FactoryGirl.create(:space) }
      before do
        space1.add_member!(user, 'User')
        space2.add_member!(user, 'Admin')
        @activity1 = RecentActivity.create(:owner => space1)
        @activity2 = RecentActivity.create(:owner => space2)
        @activity3 = RecentActivity.create(:owner => space3)
      end
      subject { user.all_activity }
      it { subject.length.should be(2) }
      it { subject[0].should eq(@activity1) }
      it { subject[1].should eq(@activity2) }
    end

    context "returns the activities in the rooms of his spaces" do
      let(:space1) { FactoryGirl.create(:space) }
      let(:space2) { FactoryGirl.create(:space) }
      let(:space3) { FactoryGirl.create(:space) }
      before do
        space1.add_member!(user, 'User')
        space2.add_member!(user, 'Admin')
        @activity1 = RecentActivity.create(:owner => space1.bigbluebutton_room)
        @activity2 = RecentActivity.create(:owner => space2.bigbluebutton_room)
        @activity3 = RecentActivity.create(:owner => space3.bigbluebutton_room)
      end
      subject { user.all_activity }
      it { subject.length.should be(2) }
      it { subject[0].should eq(@activity1) }
      it { subject[1].should eq(@activity2) }
    end
  end

  describe "#fellows" do
    context "returns the fellows of the current user" do
      let(:user) { FactoryGirl.create(:user) }
      subject { user.fellows }
      before do
        space = FactoryGirl.create(:space)
        space.add_member! user
        @users = Helpers.create_fellows(2, space)
        # 2 no fellows
        2.times { FactoryGirl.create(:user) }
      end
      it { subject.length.should == 2 }
      it { should include(@users[0]) }
      it { should include(@users[1]) }
    end

    context "filters by name" do
      let(:user) { FactoryGirl.create(:user) }
      subject { user.fellows("another") }
      before do
        space = FactoryGirl.create(:space)
        space.add_member! user
        @fellows = Helpers.create_fellows(3, space)
        @fellows[0].profile.update_attribute(:full_name, "Yet Another User")
        @fellows[1].profile.update_attribute(:full_name, "Abc de Fgh")
        @fellows[2].profile.update_attribute(:full_name, "Marcos da Silva")
      end
      it { subject.length.should == 1 }
      it { should include(@fellows[0]) }
    end

    context "orders by name" do
      let(:user) { FactoryGirl.create(:user) }
      subject { user.fellows }
      before do
        space = FactoryGirl.create(:space)
        space.add_member! user
        @users = Helpers.create_fellows(5, space)
        @users.sort!{ |x, y| x.name <=> y.name }
      end
      it { subject.length.should == 5 }
      it { should == @users }
    end

    context "don't return duplicates" do
      let(:user) { FactoryGirl.create(:user) }
      subject { user.fellows }
      before do
        space1 = FactoryGirl.create(:space)
        space2 = FactoryGirl.create(:space)
        space1.add_member! user
        space2.add_member! user
        @fellow = FactoryGirl.create(:user)
        space1.add_member! @fellow
        space2.add_member! @fellow
      end
      it { subject.length.should == 1 }
      it { should include(@fellow) }
    end

    context "don't return the user himself" do
      let(:user) { FactoryGirl.create(:user) }
      subject { user.fellows }
      before do
        space = FactoryGirl.create(:space)
        space.add_member! user
        @users = Helpers.create_fellows(2, space)
      end
      it { subject.length.should == 2 }
      it { should include(@users[0]) }
      it { should include(@users[1]) }
      it { should_not include(user) }
    end

    context "limits the results" do
      let(:user) { FactoryGirl.create(:user) }
      subject { user.fellows(nil, 3) }
      before do
        space = FactoryGirl.create(:space)
        space.add_member! user
        Helpers.create_fellows(10, space)
      end
      it { subject.length.should == 3 }
    end

    context "limits to 5 results by default" do
      let(:user) { FactoryGirl.create(:user) }
      subject { user.fellows }
      before do
        space = FactoryGirl.create(:space)
        space.add_member! user
        Helpers.create_fellows(10, space)
      end
      it { subject.length.should == 5 }
    end

    context "limits to a maximum of 50 results" do
      let(:user) { FactoryGirl.create(:user) }
      subject { user.fellows(nil, 51) }
      before do
        space = FactoryGirl.create(:space)
        space.add_member! user
        Helpers.create_fellows(60, space)
      end
      it { subject.length.should == 50 }
    end
  end

  describe ".with_disabled" do
    let(:user1) { FactoryGirl.create(:user, :disabled => true) }
    let(:user2) { FactoryGirl.create(:user, :disabled => false) }

    context "finds users even if disabled" do
      subject { User.with_disabled.all }
      it { should include(user1) }
      it { should include(user2) }
    end

    context "returns a Relation object" do
      it { User.with_disabled.should be_an_instance_of(ActiveRecord::Relation) }
    end
  end

  describe "#approve!" do
    let(:user) { FactoryGirl.create(:user, :approved => false) }
    let(:params) {
      { :username => "any", :email => "any@jaloo.com", :approved => false, :password => "123456" }
    }

    context "sets the user as approved" do
      before { user.approve! }
      it { user.approved.should be_true }
    end

    context "throws an exception if fails to update the user" do
      it {
        user.should_receive(:update_attributes) { throw Exception.new }
        expect { user.approve! }.to raise_error
      }
    end
  end

  describe "#disapprove!" do
    let(:user) { FactoryGirl.create(:user, :approved => true) }
    let(:params) {
      { :username => "any", :email => "any@jaloo.com", :approved => false, :password => "123456" }
    }

    context "sets the user as disapproved" do
      before { user.disapprove! }
      it { user.approved.should be_false }
    end

    context "throws an exception if fails to update the user" do
      it {
        user.should_receive(:update_attributes) { throw Exception.new }
        expect { user.approve! }.to raise_error
      }
    end
  end

  describe "#active_for_authentication?" do
    context "if #require_registration_approval is set in the current site" do
      before { Site.current.update_attributes(:require_registration_approval => true) }

      context "true if the user was approved" do
        let(:user) { FactoryGirl.create(:user, :approved => true) }
        it { user.active_for_authentication?.should be_true }
      end

      context "false if the user was not approved" do
        let(:user) { FactoryGirl.create(:user, :approved => false) }
        it { user.active_for_authentication?.should be_false }
      end
    end

    context "if #require_registration_approval is not set in the current site" do
      context "true even if the user was not approved" do
        let(:user) { FactoryGirl.create(:user, :approved => false) }
        it { user.active_for_authentication?.should be_true }
      end
    end
  end

  describe "#inactive_message" do
    context "if #require_registration_approval is set in the current site" do
      before { Site.current.update_attributes(:require_registration_approval => true) }

      context "if the user was approved" do
        let(:user) { FactoryGirl.create(:user, :approved => true) }
        it { user.inactive_message.should be(:inactive) }
      end

      context "if the user was not approved" do
        let(:user) { FactoryGirl.create(:user, :approved => false) }
        it { user.inactive_message.should be(:not_approved) }
      end
    end

    context "if #require_registration_approval is not set in the current site" do
      context "ignores the fact that the user was not approved" do
        let(:user) { FactoryGirl.create(:user, :approved => false) }
        it { user.inactive_message.should be(:inactive) }
      end
    end
  end

  describe "abilities", :abilities => true do
    set_custom_ability_actions([:fellows, :current, :select, :approve])

    subject { ability }
    let(:ability) { Abilities.ability_for(user) }
    let(:target) { FactoryGirl.create(:user) }

    context "when is the user himself" do
      let(:user) { target }
      it {
        allowed = [:read, :edit, :update, :destroy, :fellows, :current, :select]
        should_not be_able_to_do_anything_to(target).except(allowed)
      }

      context "and he is disabled" do
        before { target.disable() }
        it { should_not be_able_to_do_anything_to(target) }
      end
    end

    context "when is another normal user" do
      let(:user) { FactoryGirl.create(:user) }
      it { should_not be_able_to_do_anything_to(target).except([:read, :current, :fellows, :select]) }

      context "and the target user is disabled" do
        before { target.disable() }
        it { should_not be_able_to_do_anything_to(target) }
      end
    end

    context "when is a superuser" do
      let(:user) { FactoryGirl.create(:superuser) }
      it { should be_able_to(:manage, target) }

      context "and the target user is disabled" do
        before { target.disable() }
        it { should be_able_to(:manage, target) }
      end

      context "he can do anything" do
        it { should be_able_to(:manage, :all) }
      end
    end

    context "when is an anonymous user" do
      let(:user) { User.new }
      it { should_not be_able_to_do_anything_to(target).except([:read, :current]) }

      context "and the target user is disabled" do
        before { target.disable() }
        it { should_not be_able_to_do_anything_to(target) }
      end
    end
  end

end
