# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe RecentActivity do

  describe "#user_activity" do
    let(:user) { FactoryGirl.create(:user) }

    context "returns the activities in his room" do
      let(:another_user) { FactoryGirl.create(:user) }
      before do
        @activity1 = RecentActivity.create(:owner => user.bigbluebutton_room)
        @activity2 = RecentActivity.create(:owner => another_user.bigbluebutton_room)
      end
      subject { RecentActivity.user_activity(user) }
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
      subject { RecentActivity.user_activity(user) }
      it { subject.length.should be(2) }
      it { subject[0].should eq(@activity1) }
      it { subject[1].should eq(@activity2) }
    end

    context "returns the activities in his spaces when the space is a 'trackable'" do
      let(:space1) { FactoryGirl.create(:space) }
      let(:space2) { FactoryGirl.create(:space) }
      let(:space3) { FactoryGirl.create(:space) }
      before do
        space1.add_member!(user, 'User')
        space2.add_member!(user, 'Admin')
        @activity1 = RecentActivity.create(:trackable => space1)
        @activity2 = RecentActivity.create(:trackable => space2)
        @activity3 = RecentActivity.create(:trackable => space3)
      end
      subject { RecentActivity.user_activity(user) }
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
      subject { RecentActivity.user_activity(user) }
      it { subject.length.should be(2) }
      it { subject[0].should eq(@activity1) }
      it { subject[1].should eq(@activity2) }
    end

    context "rejects keys if they are informed" do
      let(:space) { FactoryGirl.create(:space) }
      before do
        space.add_member!(user, 'User')
        @activity1 = RecentActivity.create(owner: space, key: "key1")
        @activity2 = RecentActivity.create(owner: space, key: "key2")
        @activity3 = RecentActivity.create(owner: space, key: "key3")
      end
      subject { RecentActivity.user_activity(user, ["key1", "key2"]) }
      it { subject.length.should be(1) }
      it { subject[0].should eq(@activity3) }
    end
  end

  describe "#user_public_activity" do
    let(:user) { FactoryGirl.create(:user) }

    skip 'test it returns only activities performed by the user'

    context "ignores declined join requests" do
      before {
        RecentActivity.should_receive(:user_activity) { |user, arg|
          arg.should be_an_instance_of(Array)
          arg.should include("space.decline")
        }.and_return("all activity")
      }
      it { RecentActivity.user_public_activity(user).should eql("all activity") }
    end
  end
end