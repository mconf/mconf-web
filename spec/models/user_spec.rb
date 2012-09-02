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

  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:username) }

  it "should create the user's profile after creating the user" do
    user = FactoryGirl.create(:user)
    user.profile.should_not be_nil
    user.profile.should be_an_instance_of(Profile)
  end

  it "should create the user's webconf room after creating the user" do
    user = FactoryGirl.create(:user)
    user.bigbluebutton_room.should_not be_nil
    user.bigbluebutton_room.should be_an_instance_of(BigbluebuttonRoom)
  end

  [ :receive_digest ].each do |attribute|
    it { should allow_mass_assignment_of(attribute) }
  end

  describe "#bigbluebutton_room" do
    it { should have_one(:bigbluebutton_room).dependent(:destroy) }
    it { should accept_nested_attributes_for(:bigbluebutton_room) }
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

end
