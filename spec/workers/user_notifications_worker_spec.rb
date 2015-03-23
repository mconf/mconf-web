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

    context "if an admin creates a account for a user" do
      let(:user) { FactoryGirl.create(:user) }
      before {
        Site.current.update_attributes(require_registration_approval: false)
      }

      context "the user should be notified" do
        let!(:activity) { RecentActivity.create(key: 'user.created_by_admin', trackable: user, notified: false) }

        before(:each) { worker.perform }

          it { expect(UserRegisteredByAdminSenderWorker).to have_queue_size_of(1) }
          it { expect(UserRegisteredByAdminSenderWorker).to have_queued(activity.id) }
      end
    end

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
          let!(:admin1) { FactoryGirl.create(:superuser) }
          let!(:user1) { FactoryGirl.create(:user, approved: false) }
          let!(:user2) { FactoryGirl.create(:user, approved: false) }
          before {
            RecentActivity.where(key: 'user.created', trackable_id: [user1.id, user2.id])
              .each { |act|
                act.update_attributes(notified: true)
              }
          }
          before(:each) { worker.perform }

          it { expect(UserNeedsApprovalSenderWorker).to have_queue_size_of(0) }
        end

        context "ignores users that were already approved" do
          let!(:admin) { FactoryGirl.create(:superuser) }
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

        context "when the target user cannot be found" do
          let!(:admin) { FactoryGirl.create(:superuser) }
          let!(:user1) { FactoryGirl.create(:user, approved: false) }

          before(:each) {
            activity = RecentActivity.where(key: 'user.created', trackable: user1).first
            activity.update_attribute(:trackable_id, 0)
            puts activity.inspect
            worker.perform
          }

          it { expect(UserNeedsApprovalSenderWorker).to have_queue_size_of(0) }
        end
      end

      context "notifies users when they are approved" do

        context "for multiple users" do
          let(:approver) { FactoryGirl.create(:superuser) }
          let(:user1) { FactoryGirl.create(:user, approved: false) }
          let(:activity1) { RecentActivity.where(trackable_type: 'User', key: 'user.approved',
            trackable_id: user1.id, notified: [nil, false]).first }
          let(:user2) { FactoryGirl.create(:user, approved: false) }
          let(:activity2) { RecentActivity.where(trackable_type: 'User', key: 'user.approved',
            trackable_id: user2.id, notified: [nil, false]).first }
          before {
            user1.approve!
            user1.create_approval_notification(approver)
            user2.approve!
            user2.create_approval_notification(approver)
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
        context "should generate the activities anyway" do
          it { RecentActivity.where(trackable: user1, key: 'user.created').first.should_not be_nil }
          it { RecentActivity.where(trackable: user2, key: 'user.created').first.should_not be_nil }
        end
      end

      context "doesn't notify users when they are approved" do
        let!(:user1) { FactoryGirl.create(:user, approved: true) }
        let!(:user2) { FactoryGirl.create(:user, approved: true) }

        before(:each) { worker.perform }

        it { expect(UserApprovedSenderWorker).to have_queue_size_of(0) }
      end
    end

    shared_examples "creation of activities and mails" do
      context "creates the RecentActivity" do
        it { activity.trackable.should eql @user }
        it { activity.owner.should eql token }
        it { activity.notified.should be(false) }
      end

      context "#perform sends the right mails and updates the activity" do
        before(:each) { worker.perform }

        it { expect(UserRegisteredSenderWorker).to have_queue_size_of(1) }
        it { expect(UserRegisteredSenderWorker).to have_queued(activity.id) }
      end
    end

    context "notifies the users created via Shibboleth" do
      let(:shibboleth) { Mconf::Shibboleth.new({}) }
      let(:token) { ShibToken.create!(identifier: 'any@email.com') }
      let(:activity) { RecentActivity.where(key: 'shibboleth.user.created').last }

      before {
        shibboleth.should_receive(:get_email).at_least(:once).and_return('any@email.com')
        shibboleth.should_receive(:get_login).and_return('any-login')
        shibboleth.should_receive(:get_name).and_return('Any Name')
      }
      before(:each) {
        expect { @user = shibboleth.create_user token }.to change{ User.count }.by(1)
      }

      include_examples "creation of activities and mails"
    end

    context "notifies the users created via LDAP" do
      let(:ldap) { Mconf::LDAP.new({}) }
      let(:token) { LdapToken.create!(identifier: 'any@ema.il') }
      let(:activity) { RecentActivity.where(key: 'ldap.user.created').last }

      before {
        expect {
          @user = ldap.send(:create_account, 'any@ema.il', 'any-username', 'John Doe', token)
        }.to change { User.count }.by(1)
      }

      include_examples "creation of activities and mails"
    end

    # To make sure that, if a user is approved very fast, he will receive the account
    # created email and the account approved in the right order.
    it "sends the 'account created' mail before the 'account approved'"

  end

end
