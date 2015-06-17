# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe JoinRequestsWorker do
  let(:worker) { JoinRequestsWorker }
  let(:space) { FactoryGirl.create(:space) }

  it "uses the queue :join_requests" do
    worker.instance_variable_get(:@queue).should eql(:join_requests)
  end

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
      it { expect(JoinRequestInviteSenderWorker).to have_queue_size_of(2) }
      it { expect(JoinRequestInviteSenderWorker).to have_queued(@activity[0].id) }
      it { expect(JoinRequestInviteSenderWorker).to have_queued(@activity[1].id) }
      it { expect(JoinRequestInviteSenderWorker).not_to have_queued(@activity[2].id) }
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
      it { expect(JoinRequestSenderWorker).to have_queue_size_of(2) }
      it { expect(JoinRequestSenderWorker).to have_queued(@activity[0].id) }
      it { expect(JoinRequestSenderWorker).to have_queued(@activity[1].id) }
      it { expect(JoinRequestSenderWorker).not_to have_queued(@activity[2].id) }
    end

    context "for unnotified processed requests" do
      context "enqueues all " do
        let!(:join_request1) { FactoryGirl.create(:space_join_request, group: space, :accepted => true) }
        let!(:join_request2) { FactoryGirl.create(:space_join_request, group: space, :accepted => true) }
        let!(:join_request3) { FactoryGirl.create(:space_join_request, group: space, :accepted => true) }
        before {
          # clear automatically created activities
          RecentActivity.destroy_all

          @activity1 = space.new_activity(:accept, join_request1.candidate, join_request1)
          @activity2 = space.new_activity(:accept, join_request2.candidate, join_request2)
          @activity3 = space.new_activity(:accept, join_request3.candidate, join_request3)
          @activity1.update_attribute(:notified, false)
          @activity2.update_attribute(:notified, nil)
          @activity3.update_attribute(:notified, true)
        }

        before(:each) { worker.perform }
        it { expect(ProcessedJoinRequestSenderWorker).to have_queue_size_of(2) }
        it { expect(ProcessedJoinRequestSenderWorker).to have_queued(@activity1.id) }
        it { expect(ProcessedJoinRequestSenderWorker).to have_queued(@activity2.id) }
        it { expect(ProcessedJoinRequestSenderWorker).not_to have_queued(@activity3.id) }
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

          @activity1 = space.new_activity(:decline, join_request1.candidate, join_request1)
          @activity2 = space.new_activity(:decline, join_request2.candidate, join_request2)
          @activity3 = space.new_activity(:decline, join_request3.candidate, join_request3)
        }

        before(:each) { worker.perform }
        it { expect(ProcessedJoinRequestSenderWorker).to have_queue_size_of(1) }
        it { expect(ProcessedJoinRequestSenderWorker).to have_queued(@activity2.id) }
      end

      context "ignores requests that are not owned by join requests" do
        let!(:join_request1) { FactoryGirl.create(:space_join_request, group: space, accepted: true) }
        let!(:join_request2) { FactoryGirl.create(:space_join_request, group: space, accepted: true) }
        let!(:join_request3) { FactoryGirl.create(:space_join_request, group: space, accepted: true) }
        before {
          # clear automatically created activities
          RecentActivity.destroy_all

          @activity1 = space.new_activity(:decline, join_request1.candidate, join_request1)
          @activity1.update_attributes(owner: space)
          @activity2 = space.new_activity(:decline, join_request2.candidate, join_request2)
          @activity2.update_attributes(owner: space)
          @activity3 = space.new_activity(:decline, join_request3.candidate, join_request3)
        }

        before(:each) { worker.perform }
        it { expect(ProcessedJoinRequestSenderWorker).to have_queue_size_of(1) }
        it { expect(ProcessedJoinRequestSenderWorker).to have_queued(@activity3.id) }
      end

      context "warns introducer about declined invitations" do
        let!(:join_request1) { FactoryGirl.create(:space_join_request, group: space, :request_type => 'invite') }
        let!(:join_request2) { FactoryGirl.create(:space_join_request, group: space, :request_type => 'invite', :accepted => true) }
        let!(:join_request3) { FactoryGirl.create(:space_join_request, group: space, :request_type => 'invite') }
        before {
          join_request1.update_attributes :accepted => false, :processed => true
          join_request3.update_attributes :accepted => false, :processed => true

          # clear automatically created activities
          RecentActivity.destroy_all

          @activity1 = space.new_activity(:decline, join_request1.candidate, join_request1)
          @activity2 = space.new_activity(:decline, join_request2.candidate, join_request2)
          @activity3 = space.new_activity(:decline, join_request3.candidate, join_request3)
        }

        before(:each) { worker.perform }
        it { expect(ProcessedJoinRequestSenderWorker).to have_queue_size_of(3) }
        it { expect(ProcessedJoinRequestSenderWorker).to have_queued(@activity1.id) }
        it { expect(ProcessedJoinRequestSenderWorker).to have_queued(@activity2.id) }
        it { expect(ProcessedJoinRequestSenderWorker).to have_queued(@activity3.id) }
      end
    end
  end

end
