# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe JoinRequestsNotificationsWorker do
  let(:worker) { JoinRequestsNotificationsWorker }
  let(:space) { FactoryGirl.create(:space) }

  it "uses the queue :join_requests" do
    worker.instance_variable_get(:@queue).should eql(:join_requests)
  end

  describe "#perform" do

    context "enqueues all unnotified invites" do
      let!(:join_request1) { FactoryGirl.create(:space_join_request, group: space) }
      let!(:join_request2) { FactoryGirl.create(:space_join_request, group: space) }
      let!(:join_request3) { FactoryGirl.create(:space_join_request, group: space) }
      before {
        # clear automatically created activities
        RecentActivity.destroy_all

        @activity1 = FactoryGirl.create(:join_request_invite_activity, owner: space, notified: false,
                                        trackable: join_request1)
        @activity2 = FactoryGirl.create(:join_request_invite_activity, owner: space, notified: nil,
                                        trackable: join_request2)
        @activity3 = FactoryGirl.create(:join_request_invite_activity, owner: space, notified: true,
                                        trackable: join_request3)
      }

      before(:each) { worker.perform }
      it { expect(JoinRequestInviteNotificationWorker).to have_queue_size_of(2) }
      it { expect(JoinRequestInviteNotificationWorker).to have_queued(@activity1.id) }
      it { expect(JoinRequestInviteNotificationWorker).to have_queued(@activity2.id) }
      it { expect(JoinRequestInviteNotificationWorker).not_to have_queued(@activity3.id) }
    end

    context "enqueues all unnotified requests" do
      let!(:join_request1) { FactoryGirl.create(:space_join_request, group: space) }
      let!(:join_request2) { FactoryGirl.create(:space_join_request, group: space) }
      let!(:join_request3) { FactoryGirl.create(:space_join_request, group: space) }
      before {
        # clear automatically created activities
        RecentActivity.destroy_all

        @activity1 = FactoryGirl.create(:join_request_request_activity, owner: space, notified: false,
                                        trackable: join_request1)
        @activity2 = FactoryGirl.create(:join_request_request_activity, owner: space, notified: nil,
                                        trackable: join_request2)
        @activity3 = FactoryGirl.create(:join_request_request_activity, owner: space, notified: true,
                                        trackable: join_request3)
      }

      before(:each) { worker.perform }
      it { expect(JoinRequestNotificationWorker).to have_queue_size_of(2) }
      it { expect(JoinRequestNotificationWorker).to have_queued(@activity1.id) }
      it { expect(JoinRequestNotificationWorker).to have_queued(@activity2.id) }
      it { expect(JoinRequestNotificationWorker).not_to have_queued(@activity3.id) }
    end

    context "for unnotified processed requests" do
      context "enqueues all " do
        let!(:join_request1) { FactoryGirl.create(:space_join_request, group: space) }
        let!(:join_request2) { FactoryGirl.create(:space_join_request, group: space) }
        let!(:join_request3) { FactoryGirl.create(:space_join_request, group: space) }
        before {
          # clear automatically created activities
          RecentActivity.destroy_all

          @activity1 = FactoryGirl.create(:space_join_activity, owner: space, notified: false,
                                          parameters: { join_request_id: join_request1.id })
          @activity2 = FactoryGirl.create(:space_join_activity, owner: space, notified: nil,
                                          parameters: { join_request_id: join_request2.id })
          @activity3 = FactoryGirl.create(:space_join_activity, owner: space, notified: true,
                                          parameters: { join_request_id: join_request3.id })
        }

        before(:each) { worker.perform }
        it { expect(ProcessedJoinRequestNotificationWorker).to have_queue_size_of(2) }
        it { expect(ProcessedJoinRequestNotificationWorker).to have_queued(@activity1.id) }
        it { expect(ProcessedJoinRequestNotificationWorker).to have_queued(@activity2.id) }
        it { expect(ProcessedJoinRequestNotificationWorker).not_to have_queued(@activity3.id) }
      end

      context "ignores requests with no parameters:join_request_id set" do
        let!(:join_request) { FactoryGirl.create(:space_join_request, group: space) }
        before {
          # clear automatically created activities
          RecentActivity.destroy_all

          @activity1 = FactoryGirl.create(:space_join_activity, owner: space, notified: false,
                                          parameters: { join_request_id: join_request.id })
          @activity2 = FactoryGirl.create(:space_join_activity, owner: space, notified: false)
        }

        before(:each) { worker.perform }
        it { expect(ProcessedJoinRequestNotificationWorker).to have_queue_size_of(1) }
        it { expect(ProcessedJoinRequestNotificationWorker).to have_queued(@activity1.id) }
        it { expect(ProcessedJoinRequestNotificationWorker).not_to have_queued(@activity2.id) }
      end
    end
  end

end
