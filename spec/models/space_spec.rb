# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe Space do

  it "creates a new instance given valid attributes" do
    FactoryGirl.build(:space).should be_valid
  end

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:description) }
  it {
    FactoryGirl.create(:space)
    should validate_uniqueness_of(:name)
  }

  describe "#bigbluebutton_room" do
    let(:space) { FactoryGirl.create(:space) }
    it { should have_one(:bigbluebutton_room).dependent(:destroy) }
    it { should accept_nested_attributes_for(:bigbluebutton_room) }

    it "is created when the space is created" do
      space.bigbluebutton_room.should_not be_nil
      space.bigbluebutton_room.should be_an_instance_of(BigbluebuttonRoom)
    end

    it "has the space as owner" do
      space.bigbluebutton_room.owner.should be(space)
    end

    it "has param and name equal the space's permalink" do
      space.bigbluebutton_room.param.should eql(space.permalink)
      space.bigbluebutton_room.name.should eql(space.permalink)
    end

    it "has the default logout url" do
      space.bigbluebutton_room.logout_url.should eql("/feedback/webconf/")
    end

    it "has passwords as set in the temporary attributes in the space" do
      params = {
        :_moderator_password => "random-moderator-password",
        :_attendee_password => "random-attendee-password"
      }
      space = FactoryGirl.create(:space, params)
      space.bigbluebutton_room.moderator_password.should eql(space._moderator_password)
      space.bigbluebutton_room.attendee_password.should eql(space._attendee_password)
    end

    it "is created as public is the space is public" do
      space.update_attribute(:public, true)
      space.bigbluebutton_room.private.should be_false
    end

    it "is created as private is the space is private" do
      space.update_attribute(:public, false)
      space.bigbluebutton_room.private.should be_true
    end

    pending "has the server as the first server existent"
  end

  describe "#update" do

    context "updates the webconf room" do
      let(:space) { FactoryGirl.create(:space, :name => "Old Name", :public => true) }
      before(:each) { space.update_attributes(:name => "New Name", :public => false) }
      it { space.bigbluebutton_room.param.should be(space.permalink) }
      it { space.bigbluebutton_room.name.should be(space.permalink) }
      it { space.bigbluebutton_room.private.should be(true) }
    end

  end

  describe "abilities" do
    set_custom_ability_actions([:leave])

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
