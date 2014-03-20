# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe Space do
  let(:space) { FactoryGirl.create(:space) }

  it "creates a new instance given valid attributes" do
    FactoryGirl.build(:space).should be_valid
  end

  describe "initializes with default values" do
    it("should be false by default") { Space.new.repository.should be_false }
    it("should be true if set to") { Space.new(:repository => true).repository.should be_true }
    it("should be false by default") { Space.new.public.should be_false }
    it("should be true if set to") { Space.new(:public => true).public.should be_true }
    it("should be false by default") { Space.new.disabled.should be_false }
    it("should be true if set to") { Space.new(:disabled => true).disabled.should be_true }
  end

  it { should have_many(:posts).dependent(:destroy) }
  it { should have_many(:events).dependent(:destroy) }
  it { should have_many(:news).dependent(:destroy) }
  it { should have_many(:attachments).dependent(:destroy) }
  it { should have_many(:tags).dependent(:destroy) }

  it { should have_one(:bigbluebutton_room).dependent(:destroy) }
  it { space.bigbluebutton_room.owner.should be(space) } # :as => :owner
  it { should accept_nested_attributes_for(:bigbluebutton_room) }

  it "has many permissions"
  it "has and belongs to many users"
  it "has and belongs to many admins" # there's a partial test for #admins below
  it "has many join requests"

  it { should validate_presence_of(:description) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name).case_insensitive }
  it { should ensure_length_of(:name).is_at_least(3) }

  describe "#permalink" do
    it { should validate_uniqueness_of(:permalink).case_insensitive }
    it { should validate_presence_of(:permalink) }
    it { should ensure_length_of(:permalink).is_at_least(3) }
    it { should_not allow_value("123 321").for(:permalink) }
    it { should_not allow_value("").for(:permalink) }
    it { should_not allow_value("ab@c").for(:permalink) }
    it { should_not allow_value("ab#c").for(:permalink) }
    it { should_not allow_value("ab$c").for(:permalink) }
    it { should_not allow_value("ab%c").for(:permalink) }
    it { should_not allow_value("ábcd").for(:permalink) }
    it { should allow_value("---").for(:permalink) }
    it { should allow_value("-abc").for(:permalink) }
    it { should allow_value("abc-").for(:permalink) }
    it { should allow_value("_abc").for(:permalink) }
    it { should allow_value("abc_").for(:permalink) }
    it { should allow_value("abc").for(:permalink) }
    it { should allow_value("123").for(:permalink) }
    it { should allow_value("111").for(:permalink) }
    it { should allow_value("aaa").for(:permalink) }
    it { should allow_value("___").for(:permalink) }
    it { should allow_value("abc-123_d5").for(:permalink) }

    describe "validates uniqueness against User#username" do
      describe "on create" do
        let(:user) { FactoryGirl.create(:user) }
        subject { FactoryGirl.build(:space, :permalink => user.username) }
        it { should_not be_valid }
      end

      describe "on update" do
        let(:user) { FactoryGirl.create(:user) }
        let(:space) { FactoryGirl.create(:space) }
        before(:each) {
          space.permalink = user.username
        }
        it { space.should_not be_valid }
      end
    end
  end

  it "acts_as_resource"

  it "#check_errors_on_bigbluebutton_room"

  it { should respond_to(:invitation_ids) }
  it { should respond_to(:"invitation_ids=") }

  it { should respond_to(:invitation_mails) }
  it { should respond_to(:"invitation_mails=") }

  it { should respond_to(:invite_msg) }
  it { should respond_to(:"invite_msg=") }

  it { should respond_to(:inviter_id) }
  it { should respond_to(:"inviter_id=") }

  it { should respond_to(:invitations_role_id) }
  it { should respond_to(:"invitations_role_id=") }

  it { should respond_to(:crop_x) }
  it { should respond_to(:"crop_x=") }
  it { should respond_to(:crop_y) }
  it { should respond_to(:"crop_y=") }
  it { should respond_to(:crop_w) }
  it { should respond_to(:"crop_w=") }
  it { should respond_to(:crop_h) }
  it { should respond_to(:"crop_h=") }
  it "mount_uploader :logo_image"
  it "calls :crop_logo on after_create"
  it "calls :crop_logo on after_update"

  it "default_scope :conditions"

  describe ".public" do
    context "returns the admins of the space" do
      before {
        @public1 = FactoryGirl.create(:public_space)
        @public2 = FactoryGirl.create(:public_space)
        another = FactoryGirl.create(:private_space)
      }
      it { Space.public.length.should be(2) }
      it { Space.public.should include(@public1) }
      it { Space.public.should include(@public2) }
    end
  end

  describe "::USER_ROLES" do
    it { Space::USER_ROLES.length.should be(2) }
    it { Space::USER_ROLES.should include("Admin") }
    it { Space::USER_ROLES.should include("User") }
  end

  describe "#upcoming_events" do
    context "returns the n upcoming events" do
      before {
        e1 = FactoryGirl.create(:event, :owner => space, :start_on => Time.now - 5.hours, :end_on => Time.now - 4.hours)
        e2 = FactoryGirl.create(:event, :owner => space, :start_on => Time.now + 2.hour, :end_on => Time.now + 3.hours)
        e3 = FactoryGirl.create(:event, :owner => space, :start_on => Time.now + 3.hour, :end_on => Time.now + 4.hours)
        e4 = FactoryGirl.create(:event, :owner => space, :start_on => Time.now + 1.hour, :end_on => Time.now + 2.hours)
        @expected = [e4, e2, e3]
      }
      it { space.upcoming_events(3).should eq(@expected) }
    end

    context "defaults to 5 events" do
      before {
        6.times { FactoryGirl.create(:event, :owner => space, :start_on => Time.now + 1.hour, :end_on => Time.now + 2.hours) }
      }
      it { space.upcoming_events.length.should be(5) }
    end
  end

  describe "#unique_pageviews" do
    it("if there are no stats returns 0") {
      space.unique_pageviews.should be(0)
    }
    it "returns the unique pageviews for the target space"
    it "throws an exception if the statistics are wrong"
  end

  describe "#add_member!" do
    it "adds the user as a member with the selected role"
    it "defaults the role to 'User'"
    it "doesn't add the user if he's already a member"
  end

  it "new_activity"

  describe ".with_disabled" do
    let(:space1) { FactoryGirl.create(:space, :disabled => true) }
    let(:space2) { FactoryGirl.create(:space, :disabled => false) }

    context "finds spaces even if disabled" do
      subject { Space.with_disabled.all }
      it { should include(space1) }
      it { should include(space2) }
    end

    context "returns a Relation object" do
      it { Space.with_disabled.should be_an_instance_of(ActiveRecord::Relation) }
    end
  end

  describe "#create_webconf_room" do

    it "is called when the space is created" do
      space = FactoryGirl.create(:space)
      space.bigbluebutton_room.should_not be_nil
      space.bigbluebutton_room.should be_an_instance_of(BigbluebuttonRoom)
    end

    context "creates #bigbluebutton_room" do

      it "with the space as owner" do
        space.bigbluebutton_room.owner.should be(space)
      end

      it "with param and name equal the space's permalink" do
        space.bigbluebutton_room.param.should eql(space.permalink)
        space.bigbluebutton_room.name.should eql(space.permalink)
      end

      it "with the default logout url" do
        space.bigbluebutton_room.logout_url.should eql("/feedback/webconf/")
      end

      it "as public is the space is public" do
        space = FactoryGirl.create(:space, :public => true)
        space.bigbluebutton_room.private.should be_false
      end

      it "as private is the space is private" do
        space = FactoryGirl.create(:space, :public => false)
        space.bigbluebutton_room.private.should be_true
      end

      pending "with the server as the first server existent"
    end
  end

  describe "#update_webconf_room" do
    context "updates the webconf room" do
      let(:space) { FactoryGirl.create(:space, :name => "Old Name", :public => true) }
      before(:each) { space.update_attributes(:name => "New Name", :public => false) }
      it { space.bigbluebutton_room.param.should be(space.permalink) }
      it { space.bigbluebutton_room.name.should be(space.permalink) }
      it { space.bigbluebutton_room.private.should be(true) }
    end

    it "updates to public when the space is made public" do
      space.update_attribute(:public, true)
      space.bigbluebutton_room.private.should be_false
    end

    it "updates to private when the space is made public" do
      space.update_attribute(:public, false)
      space.bigbluebutton_room.private.should be_true
    end
  end

  describe "#admins" do
    context "returns the admins of the space" do
      before {
        @u1 = FactoryGirl.create(:user)
        @u2 = FactoryGirl.create(:user)
        u3 = FactoryGirl.create(:user)
        space.add_member!(@u1, "Admin")
        space.add_member!(@u2, "Admin")
        space.add_member!(u3, "User")
      }
      it { space.admins.length.should be(2) }
      it { space.admins.should include(@u1) }
      it { space.admins.should include(@u2) }
    end
  end

  describe "abilities", :abilities => true do
    set_custom_ability_actions([:leave, :enable, :webconference, :select])

    subject { ability }
    let(:ability) { Abilities.ability_for(user) }

    context "a superuser", :user => "superuser" do
      let(:user) { FactoryGirl.create(:superuser) }

      context "in a public space" do
        let(:target) { FactoryGirl.create(:public_space) }

        context "he is not a member of" do
          it { should be_able_to_do_anything_to(target) }
        end

        context "he is a member of" do
          context "with the role 'Admin'" do
            before { target.add_member!(user, "Admin") }
            it { should be_able_to_do_anything_to(target) }
          end

          context "with the role 'User'" do
            before { target.add_member!(user, "User") }
            it { should be_able_to_do_anything_to(target) }
          end
        end
      end

      context "in a private space" do
        let(:target) { FactoryGirl.create(:private_space) }

        context "he is not a member of" do
          it { should be_able_to_do_anything_to(target) }
        end

        context "he is a member of" do
          context "with the role 'Admin'" do
            before { target.add_member!(user, "Admin") }
            it { should be_able_to_do_anything_to(target) }
          end

          context "with the role 'User'" do
            before { target.add_member!(user, "User") }
            it { should be_able_to_do_anything_to(target) }
          end
        end
      end
    end

    context "a normal user", :user => "normal" do
      let(:user) { FactoryGirl.create(:user) }

      context "in a public space" do
        let(:target) { FactoryGirl.create(:public_space) }

        context "he is not a member of" do
          it { should_not be_able_to_do_anything_to(target).except([:read, :webconference, :create, :select]) }
        end

        context "he is a member of" do
          context "with the role 'Admin'" do
            before { target.add_member!(user, "Admin") }
            it { should_not be_able_to_do_anything_to(target).except([:read, :webconference, :create, :select, :leave, :edit, :update, :destroy]) }
          end

          context "with the role 'User'" do
            before { target.add_member!(user, "User") }
            it { should_not be_able_to_do_anything_to(target).except([:read, :webconference, :create, :select, :leave]) }
          end
        end
      end

      context "in a private space" do
        let(:target) { FactoryGirl.create(:private_space) }

        context "he is not a member of" do
          it { should_not be_able_to_do_anything_to(target).except([:create, :select]) }
        end

        context "he is a member of" do
          context "with the role 'Admin'" do
            before { target.add_member!(user, "Admin") }
            it { should_not be_able_to_do_anything_to(target).except([:read, :webconference, :create, :select, :leave, :edit, :update, :destroy]) }
          end

          context "with the role 'User'" do
            before { target.add_member!(user, "User") }
            it { should_not be_able_to_do_anything_to(target).except([:read, :webconference, :create, :select, :leave]) }
          end
        end
      end
    end

    context "an anonymous user", :user => "anonymous" do
      let(:user) { User.new }

      context "in a public space" do
        let(:target) { FactoryGirl.create(:public_space) }
        it { should_not be_able_to_do_anything_to(target).except([:read, :webconference, :select]) }
      end

      context "in a private space" do
        let(:target) { FactoryGirl.create(:private_space) }
        it { should_not be_able_to_do_anything_to(target).except([:select]) }
      end
    end

  end
end
