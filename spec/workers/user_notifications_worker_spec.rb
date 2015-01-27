# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe UserNotificationsWorker do
  let(:worker) { UserNotificationsWorker }

  it "uses the queue :user_notifications" do
    worker.instance_variable_get(:@queue).should eql(:user_notifications)
  end

  describe "#perform" do

    # note: we use truncation because we remove the default admin, and using truncation
    # the seeds will automatically be reloaded after the tests
    context "if the site requires approval", with_truncation: true do
      before {
        User.destroy_all
        Site.current.update_attributes(require_registration_approval: true)
      }

      context "notifies admins when users need approval" do

        context "for multiple admins and multiple users" do
          let!(:admin1) { FactoryGirl.create(:superuser) }
          let!(:admin2) { FactoryGirl.create(:superuser) }
          let!(:user1) { FactoryGirl.create(:user, approved: false) }
          let!(:user2) { FactoryGirl.create(:user, approved: false) }
          let(:admin_ids) { User.where(superuser: true).pluck(:id) }

          before(:each) { worker.perform }

          it { expect(UserNeedsApprovalSenderWorker).to have_queue_size_of(2) }
          it { expect(UserNeedsApprovalSenderWorker).to have_queued(user1.id, admin_ids) }
          it { expect(UserNeedsApprovalSenderWorker).to have_queued(user2.id, admin_ids) }
        end

        context "ignores users not approved but that already had their notification sent" do
          let!(:user1) { FactoryGirl.create(:user, approved: false) }
          let!(:user2) { FactoryGirl.create(:user, approved: false) }

          before(:each) { worker.perform }

          it { expect(UserNeedsApprovalSenderWorker).to have_queue_size_of(0) }
        end

        context "ignores users that were already approved" do
          let!(:user1) { FactoryGirl.create(:user, approved: true) }
          let!(:user2) { FactoryGirl.create(:user, approved: true) }

          before(:each) { worker.perform }

          it { expect(UserNeedsApprovalSenderWorker).to have_queue_size_of(0) }
        end

        context "when there are no recipients" do
          let!(:user1) { FactoryGirl.create(:user, approved: false) }

          before(:each) { worker.perform }

          it { expect(UserNeedsApprovalSenderWorker).to have_queue_size_of(0) }
        end
      end

      context "notifies users when they are approved" do

        context "for multiple users" do
          let(:user1) { FactoryGirl.create(:user, approved: false) }
          let(:activity1) { RecentActivity.where(trackable_type: 'User', key: 'user.approved',
            trackable_id: user1.id, notified: [nil, false]).first }
          let(:user2) { FactoryGirl.create(:user, approved: false) }
          let(:activity2) { RecentActivity.where(trackable_type: 'User', key: 'user.approved',
            trackable_id: user2.id, notified: [nil, false]).first }
          let(:admin) { FactoryGirl.create(:user, approved: true, superuser: true) }
          before {
            user1.approve!(admin)
            user2.approve!(admin)
            worker.perform
          }

          it { expect(UserApprovedSenderWorker).to have_queue_size_of_at_least(2) }
          it { expect(UserApprovedSenderWorker).to have_queued(activity1.id) }
          it { expect(UserApprovedSenderWorker).to have_queued(activity2.id) }

        end

        context "ignores users that were not approved yet" do
          let!(:user1) { FactoryGirl.create(:user, approved: false) }
          let!(:user2) { FactoryGirl.create(:user, approved: false) }

          before(:each) { worker.perform }

          it { expect(UserApprovedSenderWorker).to have_queue_size_of(0) }
        end

        context "ignores users that already received the notification" do
          let!(:user1) { FactoryGirl.create(:user, approved: true) }
          let!(:user2) { FactoryGirl.create(:user, approved: true) }

          before(:each) { worker.perform }

          it { expect(UserApprovedSenderWorker).to have_queue_size_of(0) }
        end

      end
    end

    context "if the site does not require approval" do
      before {
        Site.current.update_attributes(require_registration_approval: false)
      }

      context "doesn't notify admins when users need approval" do
        let!(:admin1) { FactoryGirl.create(:superuser) }
        let!(:admin2) { FactoryGirl.create(:superuser) }
        let!(:user1) { FactoryGirl.create(:user, approved: false) }
        let!(:user2) { FactoryGirl.create(:user, approved: false) }

        before(:each) { worker.perform }

        it { expect(UserNeedsApprovalSenderWorker).to have_queue_size_of(0) }
      end

      context "doesn't notify users when they are approved" do
        let!(:user1) { FactoryGirl.create(:user, approved: true) }
        let!(:user2) { FactoryGirl.create(:user, approved: true) }

        before(:each) { worker.perform }

        it { expect(UserApprovedSenderWorker).to have_queue_size_of(0) }
      end

    end
  end

end
