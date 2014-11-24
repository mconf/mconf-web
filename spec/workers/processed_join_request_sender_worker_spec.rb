# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe ProcessedJoinRequestSenderWorker do
  let(:worker) { ProcessedJoinRequestSenderWorker }
  let(:space) { FactoryGirl.create(:space) }
  let(:admin) { FactoryGirl.create(:user) }
  let(:admin2) { FactoryGirl.create(:user) }

  before {
    space.add_member!(admin, 'Admin')
    space.add_member!(admin2, 'Admin')
  }

  it "uses the queue :join_requests" do
    worker.instance_variable_get(:@queue).should eql(:join_requests)
  end

  describe "#perform" do
    context "for a request" do
      let(:join_request) { FactoryGirl.create(:space_join_request, group: space) }
      let(:activity) {
        FactoryGirl.create(:space_join_activity, owner: space, notified: false,
                           parameters: { join_request_id: join_request.id })
      }

      before(:each) { worker.perform(activity.id) }
      it { SpaceMailer.should have_queue_size_of(1) }
      it { SpaceMailer.should have_queued(:processed_join_request_email, join_request.id).in(:mailer) }
      it { activity.reload.notified.should be(true) }
    end

    context "for an invite" do
      let(:join_request) { FactoryGirl.create(:space_join_request_invite, group: space) }
      let(:activity) {
        FactoryGirl.create(:space_join_activity, owner: space, notified: false,
                           parameters: { join_request_id: join_request.id })
      }

      before(:each) { worker.perform(activity.id) }
      it { SpaceMailer.should have_queue_size_of(1) }
      it { SpaceMailer.should have_queued(:processed_invitation_email, join_request.id).in(:mailer) }
      it { activity.reload.notified.should be(true) }
    end

    context "for a rejected user request" do
      let(:jr) { FactoryGirl.create(:space_join_request, group: space) }
      let(:activity) {
        FactoryGirl.create(:space_join_activity, owner: space, notified: true,
                           parameters: { join_request_id: jr.id })
      }

      before(:each) {
        jr.update_attributes :processed => true, :accepted => false
        worker.perform(activity.id)
      }

      it { SpaceMailer.should have_queue_size_of(1) }
      it { SpaceMailer.should have_queued(:processed_join_request_email, jr.id).in(:mailer) }
      it { activity.reload.notified.should be(true) }
    end

    context "for a rejected admin invite" do
      let(:jr) { FactoryGirl.create(:space_join_request_invite, group: space, introducer: admin) }
      let(:activity) {
        FactoryGirl.create(:space_join_activity, owner: space, notified: true,
                           parameters: { join_request_id: jr.id })
      }

      before(:each) {
        jr.update_attributes :processed => true, :accepted => false
        worker.perform(activity.id)
      }

      it { SpaceMailer.should have_queue_size_of(1) }
      it { SpaceMailer.should have_queued(:processed_invitation_email, jr.id).in(:mailer) }
      it { activity.reload.notified.should be(true) }
    end
  end
end
