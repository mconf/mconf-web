# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe JoinRequestInviteSenderWorker do
  let(:worker) { JoinRequestInviteSenderWorker }
  let(:space) { FactoryGirl.create(:space) }

  it "uses the queue :join_requests" do
    worker.instance_variable_get(:@queue).should eql(:join_requests)
  end

  describe "#perform" do

    context "sends the invitation email" do
      let(:join_request) { FactoryGirl.create(:space_join_request_invite, group: space) }
      let(:activity) { join_request.new_activity }
      before(:each) {
        activity.update_attribute(:notified, false)
        worker.perform(activity.id)
      }

      it { SpaceMailer.should have_queue_size_of(1) }
      it { SpaceMailer.should have_queued(:invitation_email, join_request.id).in(:mailer) }
      it { activity.reload.notified.should be(true) }
    end

    context "dont' send the invitation email if request is already notified" do
      let(:join_request) { FactoryGirl.create(:space_join_request_invite, group: space) }
      let(:activity) { join_request.new_activity }
      before(:each) {
        activity.update_attribute(:notified, true)
        worker.perform(activity.id)
      }

      it { SpaceMailer.should have_queue_size_of(0) }
      it { SpaceMailer.should_not have_queued(:invitation_email, join_request.id).in(:mailer) }
      it { activity.reload.notified.should be(true) }
    end

    context "when there's no join request set in the activity" do
      let(:activity) {
        FactoryGirl.create(:join_request_invite_activity, owner: space, notified: false, trackable: nil)
      }
      before(:each) { worker.perform(activity.id) }

      it { SpaceMailer.should have_queue_size_of(0) }
      it { activity.reload.notified.should be(true) }
    end

  end
end
