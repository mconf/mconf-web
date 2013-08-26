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

  it { should validate_presence_of(:description) }

  it { should validate_presence_of(:name) }
  it {
    space
    should validate_uniqueness_of(:name)
  }
  it { should ensure_length_of(:name).is_at_least(3) }

  it { should validate_presence_of(:permalink) }
  # it { should ensure_length_of(:permalink).is_at_least(3) }

  it { should have_many(:posts).dependent(:destroy) }
  it { should have_many(:events).dependent(:destroy) }
  it { should have_many(:news).dependent(:destroy) }
  it { should have_many(:attachments).dependent(:destroy) }
  it { should have_many(:tags).dependent(:destroy) }

  it { should have_one(:bigbluebutton_room).dependent(:destroy) }
  it { space.bigbluebutton_room.owner.should be(space) } # :as => :owner
  it { should accept_nested_attributes_for(:bigbluebutton_room) }

  it "acts_as_resource"
  it "acts_as_container"
  it "acts_as_stage"
  it "default_scope :conditions"

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

  # it { should respond_to(:default_logo) }
  # it { should respond_to(:"default_logo=") }

  it { should respond_to(:_attendee_password) }
  it { should respond_to(:"_attendee_password=") }

  it { should respond_to(:_moderator_password) }
  it { should respond_to(:"_moderator_password=") }

  describe "::USER_ROLES" do
    it { Space::USER_ROLES.length.should be(2) }
    it { Space::USER_ROLES.should include("Admin") }
    it { Space::USER_ROLES.should include("User") }
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

      it "with passwords as set in the temporary attributes in the space" do
        params = {
          :_moderator_password => "random-moderator-password",
          :_attendee_password => "random-attendee-password"
        }
        space = FactoryGirl.create(:space, params)
        space.bigbluebutton_room.moderator_password.should eql(space._moderator_password)
        space.bigbluebutton_room.attendee_password.should eql(space._attendee_password)
      end

      it "as public is the space is public" do
        space.update_attribute(:public, true)
        space.bigbluebutton_room.private.should be_false
      end

      it "as private is the space is private" do
        space.update_attribute(:public, false)
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
  end

  it "#check_permalink"

  describe "#upcoming_events" do
    context "returns the n upcoming events" do
      before {
        e1 = FactoryGirl.create(:event, :space => space, :start_date => Time.now - 5.hours, :end_date => Time.now - 4.hours)
        e2 = FactoryGirl.create(:event, :space => space, :start_date => Time.now + 2.hour, :end_date => Time.now + 3.hours)
        e3 = FactoryGirl.create(:event, :space => space, :start_date => Time.now + 3.hour, :end_date => Time.now + 4.hours)
        e4 = FactoryGirl.create(:event, :space => space, :start_date => Time.now + 1.hour, :end_date => Time.now + 2.hours)
        @expected = [e4, e2, e3]
      }
      it { space.upcoming_events(3).should eq(@expected) }
    end

    context "defaults to 5 events" do
      before {
        6.times { FactoryGirl.create(:event, :space => space, :start_date => Time.now + 1.hour, :end_date => Time.now + 2.hours) }
      }
      it { space.upcoming_events.length.should be(5) }
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

  describe "#unique_pageviews" do
    it("if there are no stats returns 0") {
      space.unique_pageviews.should be(0)
    }
    it "returns the unique pageviews for the target space"
    it "throws an exception if the statistics are wrong"
  end

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

  describe "#add_member!" do
    it "adds the user as a member with the selected role"
    it "defaults the role to 'User'"
    it "doesn't add the user if he's already a member"
  end

  describe "abilities" do
    set_custom_ability_actions([:leave, :enable])

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
          it { should_not be_able_to_do_anything_to(target).except([:read, :create]) }
        end

        context "he is a member of" do
          context "with the role 'Admin'" do
            before { target.add_member!(user, "Admin") }
            it { should_not be_able_to_do_anything_to(target).except([:read, :create, :leave, :update, :destroy]) }
          end

          context "with the role 'User'" do
            before { target.add_member!(user, "User") }
            it { should_not be_able_to_do_anything_to(target).except([:read, :create, :leave]) }
          end
        end
      end

      context "in a private space" do
        let(:target) { FactoryGirl.create(:private_space) }

        context "he is not a member of" do
          it { should_not be_able_to_do_anything_to(target).except(:create) }
        end

        context "he is a member of" do
          context "with the role 'Admin'" do
            before { target.add_member!(user, "Admin") }
            it { should_not be_able_to_do_anything_to(target).except([:read, :create, :leave, :update, :destroy]) }
          end

          context "with the role 'User'" do
            before { target.add_member!(user, "User") }
            it { should_not be_able_to_do_anything_to(target).except([:read, :create, :leave]) }
          end
        end
      end
    end

    context "an anonymous user", :user => "anonymous" do
      let(:user) { User.new }

      context "in a public space" do
        let(:target) { FactoryGirl.create(:public_space) }
        it { should_not be_able_to_do_anything_to(target).except(:read) }
      end

      context "in a private space" do
        let(:target) { FactoryGirl.create(:private_space) }
        it { should_not be_able_to_do_anything_to(target) }
      end
    end

  end
end
