# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe JoinRequestSenderWorker do
  let(:worker) { JoinRequestSenderWorker }
  let(:space) { FactoryGirl.create(:space) }

  it "uses the queue :join_requests" do
    worker.instance_variable_get(:@queue).should eql(:join_requests)
  end

  describe "#perform" do
    let(:join_request) { FactoryGirl.create(:space_join_request, group: space) }
    let(:activity) {
      FactoryGirl.create(:join_request_request_activity, owner: space, notified: false, trackable: join_request)
    }

    context "for a space with one admin" do
      let(:admin) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user) }
      before {
        space.add_member!(admin, "Admin")
        space.add_member!(user, "User")
      }
      before(:each) { worker.perform(activity.id) }

      it { SpaceMailer.should have_queue_size_of(1) }
      it { SpaceMailer.should have_queued(:join_request_email, join_request.id, admin.id).in(:mailer) }
      it { SpaceMailer.should_not have_queued(:join_request_email, join_request.id, user.id).in(:mailer) }
      it { activity.reload.notified.should be(true) }
    end

    context "for a space with several admins" do
      let(:admin1) { FactoryGirl.create(:user) }
      let(:admin2) { FactoryGirl.create(:user) }
      let(:admin3) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user) }
      before {
        space.add_member!(admin1, "Admin")
        space.add_member!(admin2, "Admin")
        space.add_member!(admin3, "Admin")
        space.add_member!(user, "User")
      }
      before(:each) { worker.perform(activity.id) }

      it { SpaceMailer.should have_queue_size_of(3) }
      it { SpaceMailer.should have_queued(:join_request_email, join_request.id, admin1.id).in(:mailer) }
      it { SpaceMailer.should have_queued(:join_request_email, join_request.id, admin2.id).in(:mailer) }
      it { SpaceMailer.should have_queued(:join_request_email, join_request.id, admin3.id).in(:mailer) }
      it { SpaceMailer.should_not have_queued(:join_request_email, join_request.id, user.id).in(:mailer) }
      it { activity.reload.notified.should be(true) }
    end

    context "for a space without admins" do
      let(:user1) { FactoryGirl.create(:user) }
      let(:user2) { FactoryGirl.create(:user) }
      before {
        space.add_member!(user1, "User")
        space.add_member!(user2, "User")
      }
      before(:each) { worker.perform(activity.id) }

      it { SpaceMailer.should have_queue_size_of(0) }
      it { SpaceMailer.should_not have_queued(:join_request_email, join_request.id, user1.id).in(:mailer) }
      it { SpaceMailer.should_not have_queued(:join_request_email, join_request.id, user2.id).in(:mailer) }
      it { activity.reload.notified.should be(true) }
    end

    context "when there's no space set in the activity" do
      before {
        activity.update_attributes(owner: nil)
      }
      before(:each) { worker.perform(activity.id) }

      it { SpaceMailer.should have_queue_size_of(0) }
      it { activity.reload.notified.should be(true) }
    end

  end
end
