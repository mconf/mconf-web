# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe BigbluebuttonMeetingObserver do

  context "after_create" do
    let(:room) { FactoryGirl.create(:bigbluebutton_room) }

    context "if the meeting is saved successfully creates an activity" do
      before(:each) {
        expect {
          params = { :room => room, :meetingid => room.meetingid, :start_time => Date.new }
          @meeting = BigbluebuttonMeeting.create(params)
        }.to change{ PublicActivity::Activity.count }.by(1)
      }
      subject { PublicActivity::Activity.last }
      it("sets #trackable") { subject.trackable.should eq(@meeting) }
      it("sets #owner") { subject.owner.should eq(room) }
      it("sets #key") { subject.key.should eq('bigbluebutton_meeting.create') }
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

end
