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

    context "if the site does not require approval" do
      before {
        Site.current.update_attributes(require_registration_approval: false)
      }

      context "doesn't notify admins when spaces don't need approval" do
        let!(:admin1) { FactoryGirl.create(:superuser) }
        let!(:admin2) { FactoryGirl.create(:superuser) }
        let!(:space1) { FactoryGirl.create(:space, approved: false) }
        let!(:space2) { FactoryGirl.create(:space, approved: false) }

        before(:each) {
          space1.new_activity('create', FactoryGirl.create(:user))
          space2.new_activity('create', FactoryGirl.create(:user))

          worker.perform
        }

        it { expect(SpaceNeedsApprovalSenderWorker).to have_queue_size_of(0) }
      end
    end

  end

end
