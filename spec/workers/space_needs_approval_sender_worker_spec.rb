# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe SpaceNeedsApprovalSenderWorker do
  let(:worker) { SpaceNeedsApprovalSenderWorker }

  before {
    Site.current.update_attributes(require_space_approval: true)
  }

  it "uses the queue :space_notifications" do
    worker.instance_variable_get(:@queue).should eql(:space_notifications)
  end

  describe "#perform" do
    let(:user) { FactoryGirl.create(:user) }
    let(:space) { FactoryGirl.create(:space) }
    let(:activity) { RecentActivity.where(trackable_type: 'Space', key: 'space.create',
      trackable_id: space.id, notified: [false, nil]).first }

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
        worker.perform(activity.id, recipient_ids)
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

      before(:each) { worker.perform(activity.id, recipient_ids) }

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
        worker.perform(activity.id, recipient_ids)
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

end
