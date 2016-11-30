# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe BigbluebuttonMeeting do

  describe "from initializers/bigbluebutton_rails" do
    context "should include PublicActivity::Common" do
      # checks a few methods included by PublicActivity::Common, but not all
      subject { BigbluebuttonMeeting.new }
      it { subject.should respond_to(:create_activity) }
      it { subject.should respond_to(:public_activity_enabled?) }
      it { subject.should respond_to(:activity_owner) }
      it { subject.should respond_to(:activity_key) }
      it { subject.should respond_to(:activity_params) }
    end
  end

  context "after_create" do
    let(:room) { FactoryGirl.create(:bigbluebutton_room) }
    let!(:user) { FactoryGirl.create(:user) }

    context "if the meeting is saved successfully creates an activity" do
      before(:each) {
        expect {
          PublicActivity.with_tracking do
            params = { room: room, meetingid: room.meetingid, create_time: DateTime.now,
                       creator_id: user.id, creator_name: user.full_name }
            @meeting = BigbluebuttonMeeting.create(params)
          end
        }.to change{ PublicActivity::Activity.count }.by(1)
      }
      subject { PublicActivity::Activity.last }
      it("sets #trackable") { subject.trackable.should eq(@meeting) }
      it("sets #owner") { subject.owner.should eq(room) }
      it("sets #key") { subject.key.should eq('bigbluebutton_meeting.create') }
      it("sets #parameters") {
        subject.parameters.should be_a(Hash)
        subject.parameters[:creator_id].should eq(user.id)
        subject.parameters[:creator_username].should eq(user.username)
      }
      it("doesn't set #recipient") { subject.recipient.should be_nil }
    end

    context "if the meeting has errors" do
      it("doesn't create an activity") {
        expect {
          BigbluebuttonMeeting.create(:room => room)
        }.not_to change{ PublicActivity::Activity.count }
      }
    end
  end

  # This is a model from BigbluebuttonRails, but we have permissions set in cancan for it,
  # so we test them here.
  describe "abilities", :abilities => true do
    # TODO: permission control for meetings
  end

end
