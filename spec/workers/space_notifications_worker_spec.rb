# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe SpaceNotificationsWorker, type: :worker do
  let(:worker) { SpaceNotificationsWorker }
  let(:queue) { Queue::High }
  let(:paramsNA) {{"method"=>:needs_approval_sender, "class"=>worker.to_s}}
  let(:paramsA) {{"method"=>:approved_sender, "class"=>worker.to_s}}

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
          let(:admin_ids) { User.superusers.ids }

          before(:each) {
            space.add_member!(space_admin, 'Admin')
            space.new_activity('create', space_admin)
            worker.perform
          }

          it { expect(queue).to have_queue_size_of(1) }
          it { expect(queue).to have_queued(paramsNA, activity.id, admin_ids) }
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

          it { expect(queue).to have_queue_size_of(0) }
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

          it { expect(queue).to have_queue_size_of(0) }
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

          it { expect(queue).to have_queue_size_of(0) }
        end
      end

      context "notifies space admins when the space is approved" do

        context "for multiple admins" do
          let(:space1) { FactoryGirl.create(:space, approved: false) }
          let(:activity1) { RecentActivity.where(key: 'space.approved', trackable_id: space1.id).first }
          let(:space2) { FactoryGirl.create(:space, approved: false) }
          let(:activity2) { RecentActivity.where(key: 'space.approved', trackable_id: space2.id).first }

          before {
            space1.approve!
            space1.add_member!(FactoryGirl.create(:user), 'Admin')
            space1.new_activity('create', space1.admins.first)
            space2.approve!
            space2.add_member!(FactoryGirl.create(:user), 'Admin')
            space2.new_activity('create', space2.admins.first)
            worker.perform
          }

          it { expect(queue).to have_queue_size_of_at_least(2) }
          it { expect(queue).to have_queued(paramsA, activity1.id) }
          it { expect(queue).to have_queued(paramsA, activity2.id) }
        end

        context "ignores spaces that were not approved yet" do
          let!(:space1) { FactoryGirl.create(:space, approved: false) }
          let!(:space2) { FactoryGirl.create(:space, approved: false) }

          before(:each) {
            space1.add_member!(FactoryGirl.create(:user), 'Admin')
            space2.add_member!(FactoryGirl.create(:user), 'Admin')
            worker.perform
          }

          it { expect(queue).to have_queue_size_of(0) }
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

        it { expect(queue).to have_queue_size_of(0) }
      end
    end

  end

  describe "#needs_approval_sender" do
    let(:user) { FactoryGirl.create(:user) }
    let(:space) { FactoryGirl.create(:space) }
    let(:activity) { RecentActivity.where(trackable_type: 'Space', key: 'space.create',
                                          trackable_id: space.id, notified: [false, nil]).first }

    before {
      Site.current.update_attributes(require_space_approval: true)
    }

    before {
      space.new_activity('create', user)
      space.add_member!(user, 'Admin')
    }

    context "for an already notified activity" do
      let(:recipient1) { user }
      let(:recipient_ids) {
        [ recipient1.id ]
      }

      before(:each) {
        activity.update_attributes(notified: true)
        worker.needs_approval_sender(activity.id, recipient_ids)
      }

      it { SpaceMailer.should have_queue_size_of(0) }
      it { SpaceMailer.should_not have_queued(:new_space_waiting_for_approval_email, recipient1.id, space.id).in(:mailer) }
      it { activity.reload.notified.should be(true) }
    end

    context "for a single recipient" do
      let(:recipient1) { space.admins.first }
      let(:recipient_ids) {
        [ recipient1.id ]
      }

      before(:each) { worker.needs_approval_sender(activity.id, recipient_ids) }

      it { SpaceMailer.should have_queue_size_of_at_least(1) }
      it { SpaceMailer.should have_queued(:new_space_waiting_for_approval_email, recipient1.id, space.id).in(:mailer) }
      it { activity.reload.notified.should be(true) }
    end

    context "for multiple recipients" do
      before {
        space.add_member!(FactoryGirl.create(:user), 'Admin')
        space.add_member!(FactoryGirl.create(:user), 'Admin')
      }
      let(:recipient1) { space.admins[0] }
      let(:recipient2) { space.admins[1] }
      let(:recipient3) { space.admins[2] }
      let(:recipient_ids) {
        [ recipient1.id, recipient2.id, recipient3.id ]
      }

      before {
        worker.needs_approval_sender(activity.id, recipient_ids)
      }
      it { SpaceMailer.should have_queue_size_of_at_least(3) }
      it {
        SpaceMailer.should have_queued(:new_space_waiting_for_approval_email, recipient1.id, space.id).in(:mailer)
        SpaceMailer.should have_queued(:new_space_waiting_for_approval_email, recipient2.id, space.id).in(:mailer)
        SpaceMailer.should have_queued(:new_space_waiting_for_approval_email, recipient3.id, space.id).in(:mailer)
      }
      it { activity.reload.notified.should be(true) }
    end
  end

  describe "#approved_sender" do
    let(:user) { FactoryGirl.create(:user) }
    let(:space) { FactoryGirl.create(:space, approved: false) }
    let(:activity) { RecentActivity.last }
    let(:approver) { FactoryGirl.create(:user) }

    before {
      Site.current.update_attributes(require_space_approval: true)
    }

    context "when the activity has not been notified" do
      before {
        space.add_member!(user, 'Admin')
        space.approve!
        worker.approved_sender(activity.id)
      }

      it { SpaceMailer.should have_queue_size_of_at_least(1) }
      it { SpaceMailer.should have_queued(:new_space_approved_email, user.id, space.id).in(:mailer) }
      it { activity.reload.notified.should be(true) }
    end

    context "when the activity has already been notified" do
      before {
        space.add_member!(user, 'Admin')
        space.approve!
        activity.update_attributes(notified: true)
        worker.approved_sender(activity.id)
      }

      it { SpaceMailer.should have_queue_size_of_at_least(0) }
      it { SpaceMailer.should_not have_queued(:new_space_approved_email, user.id, space.id).in(:mailer) }
      it { activity.reload.notified.should be(true) }
    end
  end
end
