# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe SpaceNotificationsWorker do
  let(:worker) { SpaceNotificationsWorker }

  it "uses the queue :space_notifications" do
    worker.instance_variable_get(:@queue).should eql(:space_notifications)
  end

  describe "#perform" do

    context "if the site requires approval" do
      before {
        Site.current.update_attributes(require_space_approval: true)
      }

      context "notifies admins when spaces need approval" do

        context "for multiple admins and multiple users" do
          let(:space) { FactoryGirl.create(:space, approved: false) }
          let!(:space_admin) { FactoryGirl.create(:user) }
          let!(:admin1) { FactoryGirl.create(:superuser) }
          let!(:admin2) { FactoryGirl.create(:superuser) }
          let(:activity) { RecentActivity.last }
          let(:admin_ids) { User.where(superuser: true).ids }

          before(:each) {
            space.add_member!(space_admin, 'Admin')
            space.new_activity('create', space_admin)
            worker.perform
          }

          it { expect(SpaceNeedsApprovalSenderWorker).to have_queue_size_of(1) }
          it { expect(SpaceNeedsApprovalSenderWorker).to have_queued(activity.id, admin_ids) }
        end

        context "ignores space not approved but that already had their notification sent" do
          let!(:admin) { FactoryGirl.create(:user) }
          let!(:space1) { FactoryGirl.create(:space, approved: false) }
          let!(:space2) { FactoryGirl.create(:space, approved: false) }
          before {
            space1.add_member!(admin, 'Admin')
            space1.new_activity('create', admin)
            space2.add_member!(admin, 'Admin')
            space2.new_activity('create', admin)
            RecentActivity.where(key: 'space.create', trackable_id: [space1.id, space2.id])
              .each { |act|
                act.update_attributes(notified: true)
              }
          }
          before(:each) { worker.perform }

          it { expect(SpaceNeedsApprovalSenderWorker).to have_queue_size_of(0) }
        end

        context "ignores spaces that were already approved" do
          let!(:admin) { FactoryGirl.create(:user) }
          let!(:space1) { FactoryGirl.create(:space, approved: true) }
          let!(:space2) { FactoryGirl.create(:space, approved: true) }

          before(:each) {
            space1.add_member!(admin, 'Admin')
            space1.new_activity('create', admin)
            space2.add_member!(admin, 'Admin')
            space2.new_activity('create', admin)
            worker.perform
          }

          it { expect(SpaceNeedsApprovalSenderWorker).to have_queue_size_of(0) }
        end

        context "when the target space cannot be found" do
          let!(:admin) { FactoryGirl.create(:user) }
          let!(:space1) { FactoryGirl.create(:space, approved: false) }

          before(:each) {
            space1.add_member!(admin, 'Admin')
            space1.new_activity('create', admin)

            activity = RecentActivity.where(key: 'space.create', trackable: space1).first
            activity.update_attribute(:trackable_id, nil)
            worker.perform
          }

          it { expect(SpaceNeedsApprovalSenderWorker).to have_queue_size_of(0) }
        end
      end

      context "notifies space admins when the space is approved" do

        context "for multiple admins" do
          let(:approver) { FactoryGirl.create(:superuser) }
          let(:space1) { FactoryGirl.create(:space, approved: true) }
          let(:activity1) { RecentActivity.where(key: 'space.approved', trackable_id: space1.id).first }
          let(:space2) { FactoryGirl.create(:space, approved: true) }
          let(:activity2) { RecentActivity.where(key: 'space.approved', trackable_id: space2.id).first }

          before {
            space1.add_member!(FactoryGirl.create(:user), 'Admin')
            space1.new_activity('create', space1.admins.first)
            space1.approve!
            space1.create_approval_notification(approver)
            space2.add_member!(FactoryGirl.create(:user), 'Admin')
            space2.new_activity('create', space2.admins.first)
            space2.approve!
            space2.create_approval_notification(approver)
            worker.perform
          }

          it { expect(SpaceApprovedSenderWorker).to have_queue_size_of_at_least(2) }
          it { expect(SpaceApprovedSenderWorker).to have_queued(activity1.id) }
          it { expect(SpaceApprovedSenderWorker).to have_queued(activity2.id) }
        end

        context "ignores spaces that were not approved yet" do
          let!(:space1) { FactoryGirl.create(:space, approved: false) }
          let!(:space2) { FactoryGirl.create(:space, approved: false) }

          before(:each) {
            space1.add_member!(FactoryGirl.create(:user), 'Admin')
            space2.add_member!(FactoryGirl.create(:user), 'Admin')
            worker.perform
          }

          it { expect(SpaceApprovedSenderWorker).to have_queue_size_of(0) }
        end

      end
    end

  #   context "if the site does not require approval" do
  #     before {
  #       Site.current.update_attributes(require_registration_approval: false)
  #     }

  #     context "doesn't notify admins when users need approval" do
  #       let!(:admin1) { FactoryGirl.create(:superuser) }
  #       let!(:admin2) { FactoryGirl.create(:superuser) }
  #       let!(:user1) { FactoryGirl.create(:user, approved: false) }
  #       let!(:user2) { FactoryGirl.create(:user, approved: false) }

  #       before(:each) { worker.perform }

  #       it { expect(UserNeedsApprovalSenderWorker).to have_queue_size_of(0) }
  #       context "should generate the activities anyway" do
  #         it { RecentActivity.where(trackable: user1, key: 'user.created').first.should_not be_nil }
  #         it { RecentActivity.where(trackable_id: user2, key: 'user.created').first.should_not be_nil }
  #       end
  #     end

  #     context "doesn't notify users when they are approved" do
  #       let!(:user1) { FactoryGirl.create(:user, approved: true) }
  #       let!(:user2) { FactoryGirl.create(:user, approved: true) }

  #       before(:each) { worker.perform }

  #       it { expect(UserApprovedSenderWorker).to have_queue_size_of(0) }
  #     end
  #   end

  #   shared_examples "creation of activities and mails" do
  #     context "creates the RecentActivity" do
  #       it { activity.trackable.should eql(@user) }
  #       it { activity.notified.should be(false) }

  #       # Now working, see #1737
  #       it { activity.owner.should eql(token) }
  #     end

  #     context "#perform sends the right mails and updates the activity" do
  #       before(:each) { worker.perform }

  #       it { expect(UserRegisteredSenderWorker).to have_queue_size_of(1) }
  #       it { expect(UserRegisteredSenderWorker).to have_queued(activity.id) }
  #     end
  #   end

  #   context "notifies the users created via Shibboleth" do
  #     let(:shibboleth) { Mconf::Shibboleth.new({}) }
  #     let(:token) { ShibToken.new(identifier: 'any@email.com') }
  #     let(:activity) { RecentActivity.where(key: 'shibboleth.user.created').last }

  #     before {
  #       shibboleth.should_receive(:get_email).at_least(:once).and_return('any@email.com')
  #       shibboleth.should_receive(:get_login).and_return('any-login')
  #       shibboleth.should_receive(:get_name).and_return('Any Name')
  #     }
  #     before(:each) {
  #       expect {
  #         @user = shibboleth.create_user(token)
  #         token.user = @user
  #         token.save!
  #         shibboleth.create_notification(token.user, token) # TODO: Let's refactor in the future. see #1128
  #       }.to change{ User.count }.by(1)
  #     }

  #     include_examples "creation of activities and mails"
  #   end

  #   context "notifies the users created via LDAP" do
  #     let(:ldap) { Mconf::LDAP.new({}) }
  #     let(:token) { LdapToken.create!(identifier: 'any@ema.il') }
  #     let(:activity) { RecentActivity.where(key: 'ldap.user.created').last }

  #     before {
  #       expect {
  #         @user = ldap.send(:create_account, 'any@ema.il', 'any-username', 'John Doe', token)
  #       }.to change { User.count }.by(1)
  #     }

  #     include_examples "creation of activities and mails"
  #   end

  #   # To make sure that, if a user is approved very fast, he will receive the account
  #   # created email and the account approved in the right order.
  #   it "sends the 'account created' mail before the 'account approved'"

  end

end
