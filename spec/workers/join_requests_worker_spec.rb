# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe JoinRequestsWorker, type: :worker do
  let(:worker) { JoinRequestsWorker }
  let(:space) { FactoryGirl.create(:space) }
  let(:queue) { Queue::High }
  let(:paramsInvite) { { "method" => :invite_sender, "class" => worker.to_s } }
  let(:paramsRequest) { { "method" => :request_sender, "class" => worker.to_s } }
  let(:paramsProcRequest) { { "method" => :processed_request_sender, "class" => worker.to_s } }

  describe "#perform" do

    context "enqueues all unnotified invites" do
      let!(:join_request1) { FactoryGirl.create(:space_join_request_invite, group: space) }
      let!(:join_request2) { FactoryGirl.create(:space_join_request_invite, group: space) }
      let!(:join_request3) { FactoryGirl.create(:space_join_request_invite, group: space) }
      before {
        # clear automatically created activities
        RecentActivity.destroy_all

        @activity = [join_request1, join_request2, join_request3].map(&:new_activity)

        @activity[0].update_attribute(:notified, false)
        @activity[1].update_attribute(:notified, nil)
        @activity[2].update_attribute(:notified, true)
      }

      before(:each) { worker.perform }
      it { expect(queue).to have_queue_size_of(2) }
      it { expect(queue).to have_queued(paramsInvite, @activity[0].id) }
      it { expect(queue).to have_queued(paramsInvite, @activity[1].id) }
      it { expect(queue).not_to have_queued(paramsInvite, @activity[2].id) }
    end

    context "enqueues all unnotified requests" do
      let!(:join_request1) { FactoryGirl.create(:space_join_request, group: space) }
      let!(:join_request2) { FactoryGirl.create(:space_join_request, group: space) }
      let!(:join_request3) { FactoryGirl.create(:space_join_request, group: space) }
      before {
        # clear automatically created activities
        RecentActivity.destroy_all

        @activity = [join_request1, join_request2, join_request3].map(&:new_activity)

        @activity[0].update_attribute(:notified, false)
        @activity[1].update_attribute(:notified, nil)
        @activity[2].update_attribute(:notified, true)
      }

      before(:each) { worker.perform }
      it { expect(queue).to have_queue_size_of(2) }
      it { expect(queue).to have_queued(paramsRequest, @activity[0].id) }
      it { expect(queue).to have_queued(paramsRequest, @activity[1].id) }
      it { expect(queue).not_to have_queued(paramsRequest, @activity[2].id) }
    end

    context "for unnotified processed requests" do
      context "enqueues all " do
        let!(:join_request1) { FactoryGirl.create(:space_join_request, group: space, :accepted => true) }
        let!(:join_request2) { FactoryGirl.create(:space_join_request, group: space, :accepted => true) }
        let!(:join_request3) { FactoryGirl.create(:space_join_request, group: space, :accepted => true) }
        before {
          # clear automatically created activities
          RecentActivity.destroy_all

          @activity1 = join_request1.new_activity(:accept)
          @activity2 = join_request2.new_activity(:accept)
          @activity3 = join_request3.new_activity(:accept)
          @activity1.update_attribute(:notified, false)
          @activity2.update_attribute(:notified, nil)
          @activity3.update_attribute(:notified, true)
        }

        before(:each) { worker.perform }
        it { expect(queue).to have_queue_size_of(2) }
        it { expect(queue).to have_queued(paramsProcRequest, @activity1.id) }
        it { expect(queue).to have_queued(paramsProcRequest, @activity2.id) }
        it { expect(queue).not_to have_queued(paramsProcRequest, @activity3.id) }
      end

      context "ignores requests declined by admins" do
        let!(:join_request1) { FactoryGirl.create(:space_join_request, group: space) }
        let!(:join_request2) { FactoryGirl.create(:space_join_request, group: space, :accepted => true) }
        let!(:join_request3) { FactoryGirl.create(:space_join_request, group: space) }
        before {
          join_request1.update_attributes :accepted => false, :processed => true
          join_request3.update_attributes :accepted => false, :processed => true

          # clear automatically created activities
          RecentActivity.destroy_all

          @activity1 = join_request1.new_activity(:decline)
          @activity2 = join_request2.new_activity(:decline)
          @activity3 = join_request3.new_activity(:decline)
        }

        before(:each) { worker.perform }
        it { expect(queue).to have_queue_size_of(1) }
        it { expect(queue).to have_queued(paramsProcRequest, @activity2.id) }
      end

      #
      # Trackables on RecentActivities accept/decline are now join_requests and this is
      # unecessary
      # context "ignores requests that are not owned by join requests" do
      #   let!(:join_request1) { FactoryGirl.create(:space_join_request, group: space, accepted: true) }
      #   let!(:join_request2) { FactoryGirl.create(:space_join_request, group: space, accepted: true) }
      #   let!(:join_request3) { FactoryGirl.create(:space_join_request, group: space, accepted: true) }
      #   before {
      #     # clear automatically created activities
      #     RecentActivity.destroy_all

      #     @activity1 = join_request1.new_activity(:decline)
      #     @activity1.update_attributes(owner: space)
      #     @activity2 = join_request2.new_activity(:decline)
      #     @activity2.update_attributes(owner: space)
      #     @activity3 = join_request3.new_activity(:decline)
      #   }

      #   before(:each) { worker.perform }
      #   it { expect(ProcessedJoinRequestSenderWorker).to have_queue_size_of(1) }
      #   it { expect(ProcessedJoinRequestSenderWorker).to have_queued(@activity3.id) }
      # end

      context "warns introducer about declined invitations" do
        let!(:join_request1) { FactoryGirl.create(:space_join_request, group: space, :request_type => 'invite') }
        let!(:join_request2) { FactoryGirl.create(:space_join_request, group: space, :request_type => 'invite', :accepted => true) }
        let!(:join_request3) { FactoryGirl.create(:space_join_request, group: space, :request_type => 'invite') }
        before {
          join_request1.update_attributes :accepted => false, :processed => true
          join_request3.update_attributes :accepted => false, :processed => true

          # clear automatically created activities
          RecentActivity.destroy_all

          @activity1 = join_request1.new_activity(:decline)
          @activity2 = join_request2.new_activity(:decline)
          @activity3 = join_request3.new_activity(:decline)
        }

        before(:each) { worker.perform }
        it { expect(queue).to have_queue_size_of(3) }
        it { expect(queue).to have_queued(paramsProcRequest, @activity1.id) }
        it { expect(queue).to have_queued(paramsProcRequest, @activity2.id) }
        it { expect(queue).to have_queued(paramsProcRequest, @activity3.id) }
      end
    end
  end

  describe "#invite_sender" do

    context "sends the invitation email" do
      let(:join_request) { FactoryGirl.create(:space_join_request_invite, group: space) }
      let(:activity) { join_request.new_activity }
      before(:each) {
        activity.update_attribute(:notified, false)
        worker.invite_sender(activity.id)
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
        worker.invite_sender(activity.id)
      }

      it { SpaceMailer.should have_queue_size_of(0) }
      it { SpaceMailer.should_not have_queued(:invitation_email, join_request.id).in(:mailer) }
      it { activity.reload.notified.should be(true) }
    end

    context "when there's no join request set in the activity" do
      let(:activity) {
        FactoryGirl.create(:join_request_invite_activity, owner: space, notified: false, trackable: nil)
      }
      before(:each) { worker.invite_sender(activity.id) }

      it { SpaceMailer.should have_queue_size_of(0) }
      it { activity.reload.notified.should be(true) }
    end

  end

  describe "#request_sender" do
    let(:join_request) { FactoryGirl.create(:space_join_request, group: space) }
    let(:activity) { join_request.new_activity }
    before { activity.update_attribute(:notified, false) }

    context "for a space with one admin" do
      let(:admin) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user) }
      before {
        space.add_member!(admin, "Admin")
        space.add_member!(user, "User")
      }
      before(:each) { worker.request_sender(activity.id) }

      it { SpaceMailer.should have_queue_size_of(1) }
      it { SpaceMailer.should have_queued(:join_request_email, join_request.id, admin.id).in(:mailer) }
      it { SpaceMailer.should_not have_queued(:join_request_email, join_request.id, user.id).in(:mailer) }
      it { activity.reload.notified.should be(true) }
    end

    context "for a space with one admin but an already notified activity" do
      let(:admin) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user) }
      before {
        space.add_member!(admin, "Admin")
        space.add_member!(user, "User")
        activity.update_attributes(notified: true)
      }
      before(:each) { worker.request_sender(activity.id) }

      it { SpaceMailer.should have_queue_size_of(0) }
      it { SpaceMailer.should_not have_queued(:join_request_email, join_request.id, admin.id).in(:mailer) }
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
      before(:each) { worker.request_sender(activity.id) }

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
      before(:each) { worker.request_sender(activity.id) }

      it { SpaceMailer.should have_queue_size_of(0) }
      it { SpaceMailer.should_not have_queued(:join_request_email, join_request.id, user1.id).in(:mailer) }
      it { SpaceMailer.should_not have_queued(:join_request_email, join_request.id, user2.id).in(:mailer) }
      it { activity.reload.notified.should be(true) }
    end

    context "when there's no space set in the activity" do
      before {
        activity.update_attributes(owner: nil)
      }
      before(:each) { worker.request_sender(activity.id) }

      it { SpaceMailer.should have_queue_size_of(0) }
      it { activity.reload.notified.should be(true) }
    end

    context "when there's no join request set in the activity" do
      let(:admin) { FactoryGirl.create(:user) }
      before {
        space.add_member!(admin, "Admin")
        activity.update_attributes(trackable: nil)
      }
      before(:each) { worker.request_sender(activity.id) }

      it { SpaceMailer.should have_queue_size_of(0) }
      it { SpaceMailer.should_not have_queued(:join_request_email, activity.trackable_id, admin.id).in(:mailer) }
      it { activity.reload.notified.should be(true) }
    end

    context "when the join request was removed" do
      let(:admin) { FactoryGirl.create(:user) }
      before {
        space.add_member!(admin, "Admin")
        activity.update_attributes(trackable_id: -1, trackable_type: 'JoinRequest')
      }
      before(:each) { worker.request_sender(activity.id) }

      it { SpaceMailer.should have_queue_size_of(0) }
      it { SpaceMailer.should_not have_queued(:join_request_email, activity.trackable_id, admin.id).in(:mailer) }
      it { activity.reload.notified.should be(true) }
    end
  end

  describe "#processed_request_sender" do
    let(:admin) { FactoryGirl.create(:user) }
    let(:admin2) { FactoryGirl.create(:user) }

    before {
      space.add_member!(admin, 'Admin')
      space.add_member!(admin2, 'Admin')
    }

    context "for a request" do
      let(:join_request) { FactoryGirl.create(:space_join_request, group: space) }
      let(:activity) { join_request.new_activity :accept }

      before(:each) {
        activity.update_attribute(:notified, false)
        worker.processed_request_sender(activity.id)
      }
      it { SpaceMailer.should have_queue_size_of(1) }
      it { SpaceMailer.should have_queued(:processed_join_request_email, join_request.id).in(:mailer) }
      it { activity.reload.notified.should be(true) }
    end

    context "for an already notified request" do
      let(:join_request) { FactoryGirl.create(:space_join_request, group: space) }
      let(:activity) { join_request.new_activity :accept }

      before(:each) {
        activity.update_attribute(:notified, true)
        worker.processed_request_sender(activity.id)
      }

      it { SpaceMailer.should have_queue_size_of(0) }
      it { SpaceMailer.should_not have_queued(:processed_join_request_email, join_request.id).in(:mailer) }
      it { activity.reload.notified.should be(true) }
    end

    context "for an invite" do
      let(:join_request) { FactoryGirl.create(:space_join_request_invite, group: space) }
      let(:activity) { join_request.new_activity :accept }

      before(:each) {
        activity.update_attribute(:notified, false)
        worker.processed_request_sender(activity.id)
      }
      it { SpaceMailer.should have_queue_size_of(1) }
      it { SpaceMailer.should have_queued(:processed_invitation_email, join_request.id).in(:mailer) }
      it { activity.reload.notified.should be(true) }
    end

    context "for an already notified invite" do
      let(:join_request) { FactoryGirl.create(:space_join_request_invite, group: space) }
      let(:activity) { join_request.new_activity :accept }

      before(:each) {
        activity.update_attribute(:notified, true)
        worker.processed_request_sender(activity.id)
      }
      it { SpaceMailer.should have_queue_size_of(0) }
      it { SpaceMailer.should_not have_queued(:processed_invitation_email, join_request.id).in(:mailer) }
      it { activity.reload.notified.should be(true) }
    end

    context "for a rejected user request" do
      let(:jr) { FactoryGirl.create(:space_join_request, group: space) }
      let(:activity) { jr.new_activity :decline }

      before(:each) {
        jr.update_attributes :processed => true, :accepted => false
        worker.processed_request_sender(activity.id)
      }

      it { SpaceMailer.should have_queue_size_of(1) }
      it { SpaceMailer.should have_queued(:processed_join_request_email, jr.id).in(:mailer) }
      it { activity.reload.notified.should be(true) }
    end

    context "for a rejected admin invite" do
      let(:jr) { FactoryGirl.create(:space_join_request_invite, group: space, introducer: admin) }
      let(:activity) { jr.new_activity :decline }

      before(:each) {
        jr.update_attributes :processed => true, :accepted => false
        worker.processed_request_sender(activity.id)
      }

      it { SpaceMailer.should have_queue_size_of(1) }
      it { SpaceMailer.should have_queued(:processed_invitation_email, jr.id).in(:mailer) }
      it { activity.reload.notified.should be(true) }
    end
  end
end
