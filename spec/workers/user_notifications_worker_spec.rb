# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe UserNotificationsWorker, type: :worker do
  let(:worker) { UserNotificationsWorker }
  let(:queue) { Queue::High }
  let(:paramsRegisteredByAdmin) {{"method"=>:registered_by_admin_sender, "class"=>worker.to_s}}
  let(:paramsNeedsApproval) {{"method"=>:needs_approval_sender, "class"=>worker.to_s}}
  let(:paramsApproved) {{"method"=>:approved_sender, "class"=>worker.to_s}}
  let(:paramsRegistered) {{"method"=>:registered_sender, "class"=>worker.to_s}}
  let(:paramsCancelled) {{"method"=>:cancelled_sender, "class"=>worker.to_s}}

  describe "#perform" do

    context "if an admin creates a account for a user" do
      let(:user) { FactoryGirl.create(:user) }
      before {
        Site.current.update_attributes(require_registration_approval: false)
      }

      context "the user should be notified" do
        let!(:activity) { RecentActivity.create(key: 'user.created_by_admin', trackable: user, notified: false) }

        before(:each) { worker.perform }

          it { expect(queue).to have_queue_size_of(1) }
          it { expect(queue).to have_queued(paramsRegisteredByAdmin, activity.id) }
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
          let(:admin_ids) { User.superusers.pluck(:id) }

          before(:each) { worker.perform }

          it { expect(queue).to have_queue_size_of(2) }
          it { expect(queue).to have_queued(paramsNeedsApproval, user1.id, admin_ids) }
          it { expect(queue).to have_queued(paramsNeedsApproval, user2.id, admin_ids) }
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

          it { expect(queue).to have_queue_size_of(0) }
        end

        context "ignores users that were already approved" do
          let!(:admin) { FactoryGirl.create(:superuser) }
          let!(:user1) { FactoryGirl.create(:user, approved: true) }
          let!(:user2) { FactoryGirl.create(:user, approved: true) }

          before(:each) { worker.perform }

          it { expect(queue).to have_queue_size_of(0) }
        end

        context "when there are no recipients" do
          let!(:user1) { FactoryGirl.create(:user, approved: false) }

          before(:each) { worker.perform }

          it { expect(queue).to have_queue_size_of(0) }
        end

        context "when the target user cannot be found" do
          let!(:admin) { FactoryGirl.create(:superuser) }
          let!(:user1) { FactoryGirl.create(:user, approved: false) }

          before(:each) {
            activity = RecentActivity.where(key: 'user.created', trackable: user1).first
            activity.update_attribute(:trackable_id, 0)
            worker.perform
          }

          it { expect(queue).to have_queue_size_of(0) }
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
            user2.approve!
            worker.perform
          }

          it { expect(queue).to have_queue_size_of_at_least(2) }
          it { expect(queue).to have_queued(paramsApproved, activity1.id) }
          it { expect(queue).to have_queued(paramsApproved, activity2.id) }
        end

        context "ignores users that were not approved yet" do
          let!(:user1) { FactoryGirl.create(:user, approved: false) }
          let!(:user2) { FactoryGirl.create(:user, approved: false) }

          before(:each) { worker.perform }

          it { expect(queue).to have_queue_size_of(0) }
        end

        context "ignores users that already received the notification" do
          let!(:user1) { FactoryGirl.create(:user, approved: true) }
          let!(:user2) { FactoryGirl.create(:user, approved: true) }

          before(:each) { worker.perform }

          it { expect(queue).to have_queue_size_of(0) }
        end

      end
    end

    context "if an user account is cancelled" do
      let(:user) { FactoryGirl.create(:user) }

      context "the user should be notified" do
        let!(:activity) { RecentActivity.create(key: 'user.cancelled', trackable: user, notified: false) }

        before(:each) { worker.perform }

          it { expect(queue).to have_queue_size_of(1) }
          it { expect(queue).to have_queued(paramsCancelled, activity.id) }
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

        it { expect(queue).to have_queue_size_of(0) }
        context "should generate the activities anyway" do
          it { RecentActivity.where(trackable: user1, key: 'user.created').first.should_not be_nil }
          it { RecentActivity.where(trackable_id: user2, key: 'user.created').first.should_not be_nil }
        end
      end

      context "doesn't notify users when they are approved" do
        let!(:user1) { FactoryGirl.create(:user, approved: true) }
        let!(:user2) { FactoryGirl.create(:user, approved: true) }

        before(:each) { worker.perform }

        it { expect(queue).to have_queue_size_of(0) }
      end
    end

    shared_examples "creation of activities and mails" do
      context "creates the RecentActivity" do
        it { activity.trackable.should eql(@user) }
        it { activity.notified.should be(false) }

        # Now working, see #1737
        it { activity.owner.should eql(token) }
      end

      context "#perform sends the right mails and updates the activity" do
        before(:each) { worker.perform }

        it { expect(queue).to have_queue_size_of(1) }
        it { expect(queue).to have_queued(paramsRegistered, activity.id) }
      end
    end

    context "notifies the users created via Shibboleth" do
      let(:shibboleth) { Mconf::Shibboleth.new({}) }
      let(:token) { ShibToken.new(identifier: 'any@email.com') }
      let(:activity) { RecentActivity.where(key: 'shibboleth.user.created').last }

      before {
        shibboleth.should_receive(:get_email).at_least(:once).and_return('any@email.com')
        shibboleth.should_receive(:get_login).and_return('any-login')
        shibboleth.should_receive(:get_name).and_return('Any Name')
      }
      before(:each) {
        expect {
          @user = shibboleth.create_user(token)
          token.user = @user
          token.save!
          shibboleth.create_notification(token.user, token) # TODO: Let's refactor in the future. see #1128
        }.to change{ User.count }.by(1)
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

  describe "#needs_approval_sender" do
    let(:user) { FactoryGirl.create(:user) }
    let(:activity) { RecentActivity.where(trackable_type: 'User', key: 'user.created',
      trackable_id: user.id, notified: [false, nil]).first }

    before {
      Site.current.update_attributes(require_registration_approval: true)
    }

    context "for an already notified activity" do
      let(:recipient1) { FactoryGirl.create(:user) }
      let(:recipient_ids) {
        [ recipient1.id ]
      }

      before(:each) {
        activity.update_attributes(notified: true)
        worker.needs_approval_sender(activity.id, recipient_ids)
      }

      it { AdminMailer.should have_queue_size_of(0) }
      it { AdminMailer.should_not have_queued(:new_user_waiting_for_approval, recipient1.id, user.id).in(:mailer) }
      it { activity.reload.notified.should be(true) }
    end


    context "for a single recipient" do
      let(:recipient1) { FactoryGirl.create(:user) }
      let(:recipient_ids) {
        [ recipient1.id ]
      }

      before(:each) { worker.needs_approval_sender(activity.id, recipient_ids) }

      it { AdminMailer.should have_queue_size_of_at_least(1) }
      it { AdminMailer.should have_queued(:new_user_waiting_for_approval, recipient1.id, user.id).in(:mailer) }
      it { activity.reload.notified.should be(true) }
    end

    context "for multiple recipients" do
      let(:recipient1) { FactoryGirl.create(:user) }
      let(:recipient2) { FactoryGirl.create(:user) }
      let(:recipient3) { FactoryGirl.create(:user) }
      let(:recipient_ids) {
        [ recipient1.id, recipient2.id, recipient3.id ]
      }

      before {
        worker.needs_approval_sender(activity.id, recipient_ids)
      }
      it { AdminMailer.should have_queue_size_of_at_least(3) }
      it {
        AdminMailer.should have_queued(:new_user_waiting_for_approval, recipient1.id, user.id).in(:mailer)
        AdminMailer.should have_queued(:new_user_waiting_for_approval, recipient2.id, user.id).in(:mailer)
        AdminMailer.should have_queued(:new_user_waiting_for_approval, recipient3.id, user.id).in(:mailer)
      }
      it { activity.reload.notified.should be(true) }
    end
  end

  describe "#registered_sender" do
    let(:user) { FactoryGirl.create(:user) }

    context "when the activity is already notified" do
      let(:token) { FactoryGirl.create(:ldap_token, user: user) }
      let(:activity) {
        RecentActivity.create(
          key: 'ldap.user.created', owner: token, trackable: user, notified: false
        )
      }

      before {
        activity.update_attributes(notified: true)
        worker.registered_sender(activity.id)
      }

      it { UserMailer.should have_queue_size_of(0) }
      it { UserMailer.should_not have_queued(:registration_notification_email, user.id).in(:mailer) }
      it { activity.reload.notified.should be(true) }
    end


    context "for a user created via LDAP" do
      let(:token) { FactoryGirl.create(:ldap_token, user: user) }
      let(:activity) {
        RecentActivity.create(
          key: 'ldap.user.created', owner: token, trackable: user, notified: false
        )
      }

      before {
        worker.registered_sender(activity.id)
      }

      it { UserMailer.should have_queue_size_of_at_least(1) }
      it { UserMailer.should have_queued(:registration_notification_email, user.id).in(:mailer) }
      it { activity.reload.notified.should be(true) }
    end

    context "for a user created via Shibboleth" do
      let(:token) { FactoryGirl.create(:shib_token, user: user) }
      let(:activity) {
        RecentActivity.create(
          key: 'shib.user.created', owner: token, trackable: user, notified: false
        )
      }

      before {
        worker.registered_sender(activity.id)
      }

      it { UserMailer.should have_queue_size_of_at_least(1) }
      it { UserMailer.should have_queued(:registration_notification_email, user.id).in(:mailer) }
      it { activity.reload.notified.should be(true) }
    end
  end

  describe "#registered_by_admin_sender" do
    let(:user) { FactoryGirl.create(:user) }

    context "for a user created by an admin" do
      let(:activity) { RecentActivity.create(key: 'user.created_by_admin', trackable: user, notified: false) }

      before {
        worker.registered_by_admin_sender(activity.id)
      }

      it { UserMailer.should have_queue_size_of_at_least(1) }
      it { UserMailer.should have_queued(:registration_by_admin_notification_email, user.id).in(:mailer) }
      it { activity.reload.notified.should be(true) }
    end

    context "when the activity has already been notified" do
      let(:activity) { RecentActivity.create(key: 'user.created_by_admin', trackable: user, notified: false) }

      before {
        activity.update_attributes(notified: true)
        worker.registered_by_admin_sender(activity.id)
      }

      it { UserMailer.should have_queue_size_of(0) }
      it { UserMailer.should_not have_queued(:registration_by_admin_notification_email, user.id).in(:mailer) }
      it { activity.reload.notified.should be(true) }
    end
  end

  describe "#cancelled_sender" do
    let(:user) { FactoryGirl.create(:user) }

    context "for an account cancelled" do
      let(:activity) { RecentActivity.create(key: 'user.cancelled', trackable: user, notified: false) }

      before {
        worker.cancelled_sender(activity.id)
      }

      it { UserMailer.should have_queue_size_of_at_least(1) }
      it { UserMailer.should have_queued(:cancellation_notification_email, user.id).in(:mailer) }
      it { activity.reload.notified.should be(true) }
    end

    context "when the activity has already been notified" do
      let(:activity) { RecentActivity.create(key: 'user.cancelled', trackable: user, notified: false) }

      before {
        activity.update_attributes(notified: true)
        worker.cancelled_sender(activity.id)
      }

      it { UserMailer.should have_queue_size_of(0) }
      it { UserMailer.should_not have_queued(:cancellation_notification_email, user.id).in(:mailer) }
      it { activity.reload.notified.should be(true) }
    end
  end

  describe "#approved_sender" do
    let(:user) { FactoryGirl.create(:user, approved: false) }
    let(:activity) { RecentActivity.last }

    before {
      Site.current.update_attributes(require_registration_approval: true)
    }

    context "when the activity has not been notified" do
      before {
        user.approve!
        worker.approved_sender(activity.id)
      }

      it { AdminMailer.should have_queue_size_of_at_least(1) }
      it { AdminMailer.should have_queued(:new_user_approved, user.id).in(:mailer) }
      it { activity.reload.notified.should be(true) }
    end

    context "when the activity has already been notified" do
      before {
        user.approve!
        activity.update_attributes(notified: true)
        worker.approved_sender(activity.id)
      }

      it { AdminMailer.should have_queue_size_of_at_least(0) }
      it { AdminMailer.should_not have_queued(:new_user_approved, user.id).in(:mailer) }
      it { activity.reload.notified.should be(true) }
    end
  end
end
